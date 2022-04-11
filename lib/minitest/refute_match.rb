# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'refute_match' do
  description <<~EOS
    Use `refute_match` if expecting matcher regex to not match actual object.

    ```ruby
    assert(!pattern.match?(object))
    refute(pattern.match?(object))
    ```

    =>

    ```ruby
    refute_match(pattern, object)
    refute_match(pattern, object)
    ```
  EOS

  within_files Synvert::RAILS_MINITEST_FILES do
    # refute(pattern.match?(object))
    # =>
    # refute_match(pattern, object)
    with_node type: 'send',
              receiver: nil,
              message: 'refute',
              arguments: {
                size: 1,
                first: { type: 'send', message: 'match?', arguments: { size: 1 } }
              } do
      replace :message, with: 'refute_match'
      replace :arguments, with: '{{arguments.first.receiver}}, {{arguments.first.arguments.first}}'
    end

    # assert(!pattern.match?(object))
    # =>
    # refute_match(pattern, object)
    with_node type: 'send',
              receiver: nil,
              message: 'assert',
              arguments: {
                size: 1,
                first: {
                  type: 'send',
                  receiver: { type: 'send', message: 'match?', arguments: { size: 1 } },
                  message: '!'
                }
              } do
      replace :message, with: 'refute_match'
      replace :arguments, with: '{{arguments.first.receiver.receiver}}, {{arguments.first.receiver.arguments.first}}'
    end
  end
end
