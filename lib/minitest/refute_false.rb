# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'refute_false' do
  configure(parser: Synvert::PARSER_PARSER)

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
      group do
        replace :message, with: 'refute'
        delete 'arguments.first', and_comma: true
      end
    end

    # assert(!something)
    # =>
    # refute(something)
    find_node '.send[receiver=nil][message=assert][arguments.size=1][arguments.first=.send[receiver=.send[receiver=nil]][message=!]]' do
      group do
        replace :message, with: 'refute'
        replace :arguments, with: '{{arguments.first.receiver}}'
      end
    end
  end
end
