# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'assert_operator' do
  description <<~EOS
    Use `assert_operator` if comparing expected and actual object using operator.

    ```ruby
    assert(expected < actual)
    ```

    =>

    ```ruby
    assert_operator(expected, :<, actual)
    ```
  EOS

  within_files Synvert::RAILS_MINITEST_FILES do
    find_node ".send[receiver=nil][message=assert][arguments.size=1]
                    [arguments.first=.send[message IN (< > <= >=)][arguments.size=1]]" do
      replace :message, with: 'assert_operator'
      replace :arguments,
              with: "{{arguments.first.receiver}}, :#{node.arguments.first.message}, {{arguments.first.arguments.first}}"
    end
  end
end
