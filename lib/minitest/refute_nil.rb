# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'refute_nil' do
  description <<~EOS
    It converts minitest refute_nil.

    ```ruby
    assert(!actual.nil?)
    refute(actual.nil?)
    ```

    =>

    ```ruby
    refute_nil(actual)
    refute_nil(actual)
    ```
  EOS

  within_files 'test/**/*_test.rb' do
    # assert(!actual.nil?)
    # =>
    # refute_nil(actual)
    with_node type: 'send', receiver: nil, message: 'assert', arguments: { size: 1, first: { type: 'send', message: '!', receiver: { type: 'send', message: 'nil?' } } } do
      replace :message, with: 'refute_nil'
      replace :arguments, with: "{{arguments.first.receiver.receiver}}"
    end

    # refute(actual.nil?)
    # =>
    # refute_nil(actual)
    with_node type: 'send', receiver: nil, message: 'refute', arguments: { size: 1, first: { type: 'send', message: 'nil?' } } do
      replace :message, with: 'refute_nil'
      replace :arguments, with: "{{arguments.first.receiver}}"
    end
  end
end
