# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'assert_silent' do
  description <<~EOS
    Use `assert_silent` to assert that nothing was written to stdout and stderr.

    ```ruby
    assert_output('', '') { puts object.do_something }
    ```

    =>

    ```ruby
    assert_silent { puts object.do_something }
    ```
  EOS

  within_files Synvert::RAILS_MINITEST_FILES do
    with_node type: 'send', receiver: nil, message: 'assert_output', arguments: { size: 2, first: '', last: '' } do
      replace :message, with: 'assert_silent'
      delete :arguments, :parentheses
    end
  end
end
