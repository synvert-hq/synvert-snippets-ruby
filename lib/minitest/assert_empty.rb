# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'assert_empty' do
  description <<~EOS
    Use `refute_empty` if expecting object to be not empty.

    ```ruby
    assert(object.empty?)
    ```

    =>

    ```ruby
    assert_empty(object)
    ```
  EOS

  within_files Synvert::RAILS_MINITEST_FILES do
    with_node type: 'send', receiver: nil, message: 'assert', arguments: { size: 1, first: { type: 'send', message: 'empty?', arguments: { size: 0 } } } do
      replace :message, with: 'assert_empty'
      replace :arguments, with: '{{arguments.first.receiver}}'
    end
  end
end
