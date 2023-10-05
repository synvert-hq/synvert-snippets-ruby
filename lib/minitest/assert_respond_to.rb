# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'assert_respond_to' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    Use `assert_respond_to` if expecting object to respond to a method.

    ```ruby
    assert(object.respond_to?(some_method))
    ```

    =>

    ```ruby
    assert_respond_to(object, some_method)
    ```
  EOS

  within_files Synvert::RAILS_MINITEST_FILES do
    find_node '.send[receiver=nil][message=assert][arguments.size=1]
                    [arguments.first=.send[message=respond_to?][arguments.size=1]]' do
      group do
        replace :message, with: 'assert_respond_to'
        replace :arguments, with: '{{arguments.first.receiver}}, {{arguments.first.arguments.first}}'
      end
    end
  end
end
