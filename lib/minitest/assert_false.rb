# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'assert_false' do
  description <<~EOS
    It converts minitest assert_false.

    ```ruby
    assert_equal(false, actual)
    assert(!something)
    ```

    =>

    ```ruby
    refute(actual)
    refute(something)
    ```
  EOS

  within_files Synvert::RAILS_MINITEST_FILES do
    # assert_equal(false, actual)
    # =>
    # refute(actual)
    with_node type: 'send', receiver: nil, message: 'assert_equal', arguments: { size: 2, first: false } do
      replace :message, with: 'refute'
      delete 'arguments.first'
    end

    # assert(!something)
    # =>
    # refute(something)
    with_node type: 'send',
              receiver: nil,
              message: 'assert',
              arguments: {
                size: 1,
                first: {
                  type: 'send',
                  message: '!'
                }
              } do
      replace :message, with: 'refute'
      replace :arguments, with: '{{arguments.first.receiver}}'
    end
  end
end
