# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'refute_respond_to' do
  description <<~EOS
    Use `refute_respond_to` if expecting object to not respond to a method.

    ```ruby
    assert(!object.respond_to?(some_method))
    refute(object.respond_to?(some_method))
    ```

    =>

    ```ruby
    refute_respond_to(object, some_method)
    refute_respond_to(object, some_method)
    ```
  EOS

  within_files Synvert::RAILS_MINITEST_FILES do
    # refute(object.respond_to?(some_method))
    # =>
    # refute_respond_to(object, some_method)
    with_node type: 'send', receiver: nil, message: 'refute', arguments: { size: 1, first: { type: 'send', message: 'respond_to?', arguments: { size: 1 } } } do
      replace :message, with: 'refute_respond_to'
      replace :arguments, with: '{{arguments.first.receiver}}, {{arguments.first.arguments.first}}'
    end

    # assert(!object.respond_to?(some_method))
    # =>
    # refute_respond_to(object, some_method)
    with_node type: 'send', receiver: nil, message: 'assert', arguments: { size: 1, first: { type: 'send', receiver: { type: 'send', message: 'respond_to?', arguments: { size: 1 } }, message: '!' } } do
      replace :message, with: 'refute_respond_to'
      replace :arguments, with: '{{arguments.first.receiver.receiver}}, {{arguments.first.receiver.arguments.first}}'
    end
  end
end
