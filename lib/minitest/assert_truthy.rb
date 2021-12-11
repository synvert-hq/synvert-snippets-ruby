# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'assert_truthy' do
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
    with_node type: 'send', receiver: nil, message: 'assert_equal', arguments: { size: 2, first: true } do
      replace :message, with: 'assert'
      delete 'arguments.first'
    end
  end
end
