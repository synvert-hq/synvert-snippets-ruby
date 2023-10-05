# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'assert_truthy' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    Use `assert` if expecting truthy value.

    ```ruby
    assert_equal(true, actual)
    ```

    =>

    ```ruby
    assert(actual)
    ```
  EOS

  within_files Synvert::RAILS_MINITEST_FILES do
    find_node '.send[receiver=nil][message=assert_equal][arguments.size=2][arguments.first=true]' do
      group do
        replace :message, with: 'assert'
        delete 'arguments.first', and_comma: true
      end
    end
  end
end
