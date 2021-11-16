# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'assert_equal_arguments_order' do
  description <<~EOS
    It converts minitest assert_equal arguments order.

    ```ruby
    assert_equal(actual, "rubocop-minitest")
    ```

    =>

    ```ruby
    assert_equal("rubocop-minitest", actual)
    ```
  EOS

  within_files 'test/**/*_test.rb' do
    primitive_types = %i[str sym int float true false]
    with_node type: 'send',
              receiver: nil,
              message: 'assert_equal',
              arguments: {
                size: 2,
                second: {
                  type: {
                    in: primitive_types
                  }
                }
              } do
      replace :arguments, with: '{{arguments.second}}, {{arguments.first}}'
    end
  end
end
