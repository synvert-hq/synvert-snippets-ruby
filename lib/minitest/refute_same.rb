# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'refute_same' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    Use `refute_same` instead of `refute` with `equal?`.

    ```ruby
    refute(expected.equal?(actual))
    assert(expected.equal?(actual))
    ```

    =>

    ```ruby
    assert_same(expected, actual)
    assert_same(expected, actual)
    ```
  EOS

  within_files Synvert::RAILS_MINITEST_FILES do
    find_node '.send[receiver=nil][message=refute][arguments.size=1]
                    [arguments.0=.send[message=equal?][arguments.size=1]
                                      [arguments.0=.send[receiver=nil][arguments.size=0]]]' do
      group do
        replace :arguments, with: '{{arguments.0.receiver}}, {{arguments.0.arguments.0}}'
        replace :message, with: 'refute_same'
      end
    end

    find_node '.send[receiver=nil][message=assert][arguments.size=1]
                    [arguments.0=.send[receiver=.send[message=equal?][arguments.size=1]
                                      [arguments.0=.send[receiver=nil][arguments.size=0]]][message=!][arguments.size=0]]' do
      group do
        replace :arguments, with: '{{arguments.0.receiver.receiver}}, {{arguments.0.receiver.arguments.0}}'
        replace :message, with: 'refute_same'
      end
    end
  end
end
