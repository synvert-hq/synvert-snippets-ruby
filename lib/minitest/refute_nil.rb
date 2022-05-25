# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'refute_nil' do
  description <<~EOS
    Use `refute_nil` if not expecting `nil`.

    ```ruby
    assert(!actual.nil?)
    refute(actual.nil?)
    ```

    =>

    ```ruby
    refute_nil(actual)
    refute_nil(actual)
    ```
  EOS

  within_files Synvert::RAILS_MINITEST_FILES do
    # assert(!actual.nil?)
    # =>
    # refute_nil(actual)
    find_node '.send[receiver=nil][message=assert][arguments.size=1]
                    [arguments.first=.send[message=!][receiver=.send[message=nil?]]]' do
      replace :message, with: 'refute_nil'
      replace :arguments, with: '{{arguments.first.receiver.receiver}}'
    end

    # refute(actual.nil?)
    # =>
    # refute_nil(actual)
    find_node '.send[receiver=nil][message=refute][arguments.size=1] [arguments.first=.send[message=nil?]]' do
      replace :message, with: 'refute_nil'
      replace :arguments, with: '{{arguments.first.receiver}}'
    end
  end
end
