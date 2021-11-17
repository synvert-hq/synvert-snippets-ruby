# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'assert_nil' do
  description <<~EOS
    It converts minitest assert_nil.

    ```ruby
    assert_equal(nil, actual)
    ```

    =>

    ```ruby
    assert_nil(actual)
    ```
  EOS

  within_files Synvert::RAILS_MINITEST_FILES do
    with_node type: 'send', receiver: nil, message: 'assert_equal', arguments: { size: 2, first: nil } do
      replace :message, with: 'assert_nil'
      delete 'arguments.first'
    end
  end
end
