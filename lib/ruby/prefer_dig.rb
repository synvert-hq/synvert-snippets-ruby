# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'prefer_dig' do
  description <<~EOS
    It prefers Hash#dig

    ```ruby
    params[one] && params[one][two] && params[one][two][three]
    ```

    =>

    ```ruby
    params.dig(one, two, three)
    ```
  EOS

  within_files Synvert::ALL_FILES do
    find_node '.and[right_value=.send[message=[]][arguments.size=1]]' do
      writeable_node = node.dup
      param_names = []
      while :and == writeable_node.type && :and == writeable_node.left_value.type && writeable_node.right_value.receiver == writeable_node.left_value.right_value
        param_names << writeable_node.right_value.arguments.first.to_source
        writeable_node = writeable_node.left_value
      end
      if :and == writeable_node.type && :send == writeable_node.left_value.type && writeable_node.right_value.receiver == writeable_node.left_value &&
         :[] == writeable_node.left_value.message && writeable_node.left_value.arguments.size == 1

        param_names << writeable_node.right_value.arguments.first.to_source
        writeable_node = writeable_node.left_value

        param_names << writeable_node.arguments.first.to_source
        replace_with "#{writeable_node.receiver.to_source}.dig(#{param_names.reverse.join(', ')})"
      end
    end
  end
end
