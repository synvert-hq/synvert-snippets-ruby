# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'assert_predicate' do
  description <<~EOS
    Use `assert_predicate` if expecting to test the predicate on the expected object and on applying predicate returns true. The benefit of using the `assert_predicate` over the `assert` or `assert_equal` is the user friendly error message when assertion fails.

    ```ruby
    assert expected.zero?
    assert_equal 0, expected
    ```

    =>

    ```ruby
    assert_predicate expected, :zero?
    assert_predicate expected, :zero?
    ```
  EOS

  within_files Synvert::RAILS_MINITEST_FILES do
    # assert expected.zero?
    # =>
    # assert_predicate expected, :zero?
    find_node '.send[receiver=nil][message=assert][arguments.size=1]
                    [arguments.first=.send[message=zero?][arguments.size=0]]' do
      replace :message, with: 'assert_predicate'
      replace :arguments, with: '{{arguments.first.receiver}}, :zero?'
    end

    # assert_equal 0, expected
    # =>
    # assert_predicate expected, :zero?
    find_node '.send[receiver=nil][message=assert_equal][arguments.size=2][arguments.first=0]' do
      replace :message, with: 'assert_predicate'
      replace :arguments, with: '{{arguments.1}}, :zero?'
    end
  end
end
