# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'refute_predicate' do
  description <<~EOS
    Use `refute_predicate` if expecting to test the predicate on the expected object and on applying predicate returns false.

    ```ruby
    assert(!expected.zero?)
    refute(expected.zero?)
    ```

    =>

    ```ruby
    refute_predicate(expected, :zero?)
    refute_predicate(expected, :zero?)
    ```
  EOS

  within_files Synvert::RAILS_MINITEST_FILES do
    # refute(expected.zero?)
    # =>
    # refute_predicate(expected, :zero?)
    with_node type: 'send', receiver: nil, message: 'refute', arguments: { size: 1, first: { type: 'send', message: 'zero?', arguments: { size: 0 } } } do
      replace :message, with: 'refute_predicate'
      replace :arguments, with: '{{arguments.first.receiver}}, :zero?'
    end

    # assert(!expected.zero?)
    # =>
    # refute_predicate(expected, :zero?)
    with_node type: 'send', receiver: nil, message: 'assert', arguments: { size: 1, first: { type: 'send', receiver: { type: 'send', message: 'zero?', arguments: { size: 0 } }, message: '!' } } do
      replace :message, with: 'refute_predicate'
      replace :arguments, with: '{{arguments.first.receiver.receiver}}, :zero?'
    end
  end
end
