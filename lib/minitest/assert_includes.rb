# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'assert_includes' do
  description <<~EOS
    Use `assert_includes` to assert if the object is included in the collection.

    ```ruby
    assert(collection.include?(object))
    ```

    =>

    ```ruby
    assert_includes(collection, object)
    ```
  EOS

  within_files Synvert::RAILS_MINITEST_FILES do
    find_node '.send[receiver=nil][message=assert][arguments.size=1]
                    [arguments.first=.send[message=include?][arguments.size=1]]' do
      replace :message, with: 'assert_includes'
      replace :arguments, with: '{{arguments.first.receiver}}, {{arguments.first.arguments.first}}'
    end
  end
end
