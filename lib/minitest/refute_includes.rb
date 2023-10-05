# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'refute_includes' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    Use `refute_includes` if the object is not included in the collection.

    ```ruby
    refute(collection.include?(object))
    assert(!collection.include?(object))
    ```

    =>

    ```ruby
    refute_includes(collection, object)
    refute_includes(collection, object)
    ```
  EOS

  within_files Synvert::RAILS_MINITEST_FILES do
    # refute(collection.include?(object))
    # =>
    # refute_includes(collection, object)
    find_node '.send[receiver=nil][message=refute][arguments.size=1]
                    [arguments.first=.send[message=include?][arguments.size=1]]' do
      group do
        replace :message, with: 'refute_includes'
        replace :arguments, with: '{{arguments.first.receiver}}, {{arguments.first.arguments.first}}'
      end
    end

    # assert(!collection.include?(object))
    # =>
    # refute_includes(collection, object)
    find_node '.send[receiver=nil][message=assert][arguments.size=1]
                    [arguments.first=.send[message=!][receiver=.send[message=include?][arguments.size=1]]]' do
      group do
        replace :message, with: 'refute_includes'
        replace :arguments, with: '{{arguments.first.receiver.receiver}}, {{arguments.first.receiver.arguments.first}}'
      end
    end
  end
end
