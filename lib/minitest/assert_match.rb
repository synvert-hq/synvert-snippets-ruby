# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'assert_match' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    Use `assert_match` if expecting matcher regex to match actual object.

    ```ruby
    assert(pattern.match?(object))
    ```

    =>

    ```ruby
    assert_match(pattern, object)
    ```
  EOS

  within_files Synvert::RAILS_MINITEST_FILES do
    find_node '.send[receiver=nil][message=assert][arguments.size=1]
                    [arguments.first=.send[message=match?][arguments.size=1]]' do
      group do
        replace :message, with: 'assert_match'
        replace :arguments, with: '{{arguments.first.receiver}}, {{arguments.first.arguments.first}}'
      end
    end
  end
end
