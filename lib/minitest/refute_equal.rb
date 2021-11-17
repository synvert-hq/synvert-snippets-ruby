# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'refute_equal' do
  description <<~EOS
    It converts minitest refute_equal.

    ```ruby
    assert("rubocop-minitest" != actual)
    assert(!"rubocop-minitest" == actual)
    ```

    =>

    ```ruby
    refute_equal("rubocop-minitest", actual)
    refute_equal("rubocop-minitest", actual)
    ```
  EOS

  within_files Synvert::RAILS_MINITEST_FILES do
    # assert("rubocop-minitest" != actual)
    # =>
    # refute_equal("rubocop-minitest", actual)
    with_node type: 'send', receiver: nil, message: 'assert', arguments: { size: 1, first: { type: 'send', message: '!=' } } do
      replace :message, with: 'refute_equal'
      replace :arguments, with: "{{arguments.first.receiver}}, {{arguments.first.arguments}}"
    end

    # assert(!"rubocop-minitest" == (actual))
    # =>
    # refute_equal("rubocop-minitest", actual)
    with_node type: 'send', receiver: nil, message: 'assert', arguments: { size: 1, first: { type: 'send', message: '==', receiver: { type: 'send', message: '!' } } } do
      replace :message, with: 'refute_equal'
      replace :arguments, with: "{{arguments.first.receiver.receiver}}, {{arguments.first.arguments}}"
    end
  end
end
