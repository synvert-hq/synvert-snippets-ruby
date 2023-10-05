# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'assert_empty' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    Use `assert_empty` if expecting object to be empty.

    ```ruby
    assert(object.empty?)
    ```

    =>

    ```ruby
    assert_empty(object)
    ```
  EOS

  within_files Synvert::RAILS_MINITEST_FILES do
    find_node '.send[receiver=nil][message=assert][arguments.size=1]
                    [arguments.first=.send[message=empty?][arguments.size=0]]' do
      group do
        replace :message, with: 'assert_empty'
        replace :arguments, with: '{{arguments.first.receiver}}'
      end
    end
  end
end
