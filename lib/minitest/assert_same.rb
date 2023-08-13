# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'assert_same' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    Use `assert_same` instead of `assert` with `equal?`.

    ```ruby
    assert(expected.equal?(actual))
    ```

    =>

    ```ruby
    assert_same(expected, actual)
    ```
  EOS

  within_files Synvert::RAILS_MINITEST_FILES do
    find_node '.send[receiver=nil][message=assert][arguments.size=1]
                    [arguments.0=.send[message=equal?][arguments.size=1]
                                      [arguments.0=.send[receiver=nil][arguments.size=0]]]' do
      replace :arguments, with: '{{arguments.0.receiver}}, {{arguments.0.arguments.0}}'
      replace :message, with: 'assert_same'
    end
  end
end
