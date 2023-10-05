# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'refute_match' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    Use `refute_match` if expecting matcher regex to not match actual object.

    ```ruby
    assert(!pattern.match?(object))
    refute(pattern.match?(object))
    ```

    =>

    ```ruby
    refute_match(pattern, object)
    refute_match(pattern, object)
    ```
  EOS

  within_files Synvert::RAILS_MINITEST_FILES do
    # refute(pattern.match?(object))
    # =>
    # refute_match(pattern, object)
    find_node '.send[receiver=nil][message=refute][arguments.size=1]
                    [arguments.first=.send[message=match?][arguments.size=1]]' do
      group do
        replace :message, with: 'refute_match'
        replace :arguments, with: '{{arguments.first.receiver}}, {{arguments.first.arguments.first}}'
      end
    end

    # assert(!pattern.match?(object))
    # =>
    # refute_match(pattern, object)
    find_node '.send[receiver=nil][message=assert][arguments.size=1]
                    [arguments.first=.send[message=!][receiver=.send[message=match?][arguments.size=1]]]' do
      group do
        replace :message, with: 'refute_match'
        replace :arguments, with: '{{arguments.first.receiver.receiver}}, {{arguments.first.receiver.arguments.first}}'
      end
    end
  end
end
