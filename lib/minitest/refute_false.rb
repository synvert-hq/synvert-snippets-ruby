# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'refute_false' do
  description <<~EOS
    Use `refute` if expecting false.

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
    find_node '.send[receiver=nil][message=assert_equal][arguments.size=2][arguments.first=false]' do
      replace :message, with: 'refute'
      delete 'arguments.first', and_comma: true
    end

    # assert(!something)
    # =>
    # refute(something)
    find_node '.send[receiver=nil][message=assert][arguments.size=1] [arguments.first=.send[message=!]]' do
      replace :message, with: 'refute'
      replace :arguments, with: '{{arguments.first.receiver}}'
    end
  end
end
