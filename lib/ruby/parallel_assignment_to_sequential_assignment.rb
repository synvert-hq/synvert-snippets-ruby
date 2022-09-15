# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'parallel_assignment_to_sequential_assignment' do
  description <<~EOS
    It converts parallel assignment to sequential assignment.

    ```ruby
    a, b = 1, 2
    ```

    =>

    ```ruby
    a = 1
    b = 2
    ```
  EOS

  within_files Synvert::ALL_RUBY_FILES do
    # a, b = 1, 2
    # =>
    # a = 1
    # b = 2
    find_node '.masgn[left_value=.mlhs][right_value=.array][left_value.children.size="{{right_value.children.size}}"]' do
      replace_with node.left_value.children.zip(node.right_value.children).map { |left, right|
        "#{left.to_source} = #{right.to_source}"
      }.join("\n")
    end
  end
end
