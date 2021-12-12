# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'refute_instance_of' do
  description <<~EOS
    Prefer `refute_instance_of(class, object)` over `refute(object.instance_of?(class))`.

    ```ruby
    assert(!'rubocop-minitest'.instance_of?(String))
    refute('rubocop-minitest'.instance_of?(String))
    ```

    =>

    ```ruby
    refute_instance_of(String, 'rubocop-minitest')
    refute_instance_of(String, 'rubocop-minitest')
    ```
  EOS

  within_files Synvert::RAILS_MINITEST_FILES do
    # refute('rubocop-minitest'.instance_of?(String))
    # =>
    # refute_instance_of(String, 'rubocop-minitest')
    with_node type: 'send', receiver: nil, message: 'refute', arguments: { size: 1, first: { type: 'send', message: 'instance_of?', arguments: { size: 1 } } } do
      replace :message, with: 'refute_instance_of'
      replace :arguments, with: '{{arguments.first.arguments.first}}, {{arguments.first.receiver}}'
    end

    # assert(!'rubocop-minitest'.instance_of?(String))
    # =>
    # refute_instance_of(String, 'rubocop-minitest')
    with_node type: 'send', receiver: nil, message: 'assert', arguments: { size: 1, first: { type: 'send', receiver: { type: 'send', message: 'instance_of?', arguments: { size: 1 } }, message: '!' } } do
      replace :message, with: 'refute_instance_of'
      replace :arguments, with: '{{arguments.first.receiver.arguments.first}}, {{arguments.first.receiver.receiver}}'
    end
  end
end
