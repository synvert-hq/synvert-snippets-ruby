# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'refute_empty' do
  description <<~EOS
    Use `refute_empty` if expecting object to be not empty.

    ```ruby
    refute(object.empty?)
    assert(!object.empty?)
    ```

    =>

    ```ruby
    refute_empty(object)
    refute_empty(object)
    ```
  EOS

  within_files Synvert::RAILS_MINITEST_FILES do
    # refute(object.empty?)
    # =>
    # refute_empty(object)
    find_node '.send[receiver=nil][message=refute][arguments.size=1]
                    [arguments.first=.send[message=empty?][arguments.size=0]]' do
      replace :message, with: 'refute_empty'
      replace :arguments, with: '{{arguments.first.receiver}}'
    end

    # assert(!object.empty?)
    # =>
    # refute_empty(object)
    find_node '.send[receiver=nil][message=assert][arguments.size=1]
                    [arguments.first=.send[message=!][receiver=.send[message=empty?][arguments.size=0]]]' do
      replace :message, with: 'refute_empty'
      replace :arguments, with: '{{arguments.first.receiver.receiver}}'
    end
  end
end
