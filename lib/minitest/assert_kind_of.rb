# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'assert_kind_of' do
  description <<~EOS
    Prefer `assert_kind_of(class, object)` over `assert(object.kind_of?(class))`.

    ```ruby
    assert('rubocop-minitest'.kind_of?(String))
    ```

    =>

    ```ruby
    assert_kind_of(String, 'rubocop-minitest')
    ```
  EOS

  within_files Synvert::RAILS_MINITEST_FILES do
    with_node type: 'send', receiver: nil, message: 'assert', arguments: { size: 1, first: { type: 'send', message: 'kind_of?', arguments: { size: 1 } } } do
      replace :message, with: 'assert_kind_of'
      replace :arguments, with: '{{arguments.first.arguments.first}}, {{arguments.first.receiver}}'
    end
  end
end
