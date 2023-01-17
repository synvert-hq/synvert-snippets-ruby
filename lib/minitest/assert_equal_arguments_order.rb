# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'assert_equal_arguments_order' do
  description <<~EOS
    `assert_equal` should always have expected value as first argument because if the assertion fails the error message would say expected "rubocop-minitest" received "rubocop" not the other way around.

    ```ruby
    assert_equal(actual, "rubocop-minitest")
    ```

    =>

    ```ruby
    assert_equal("rubocop-minitest", actual)
    ```
  EOS

  within_files Synvert::RAILS_MINITEST_FILES do
    find_node ".send[receiver=nil][message=assert_equal][arguments.size=2]
                    [arguments.1.type IN (str sym int float true false)]" do
      replace :arguments, with: '{{arguments.1}}, {{arguments.first}}'
    end
  end
end
