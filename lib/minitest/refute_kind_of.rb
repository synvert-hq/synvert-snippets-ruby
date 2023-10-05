# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'refute_kind_of' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    Prefer `refute_kind_of(class, object)` over `refute(object.kind_of?(class))`.

    ```ruby
    assert(!'rubocop-minitest'.kind_of?(String))
    refute('rubocop-minitest'.kind_of?(String))

    ```

    =>

    ```ruby
    refute_kind_of(String, 'rubocop-minitest')
    refute_kind_of(String, 'rubocop-minitest')
    ```
  EOS

  within_files Synvert::RAILS_MINITEST_FILES do
    # refute('rubocop-minitest'.kind_of?(String))
    # =>
    # refute_kind_of(String, 'rubocop-minitest')
    find_node '.send[receiver=nil][message=refute][arguments.size=1]
                    [arguments.first=.send[message=kind_of?][arguments.size=1]]' do
      group do
        replace :message, with: 'refute_kind_of'
        replace :arguments, with: '{{arguments.first.arguments.first}}, {{arguments.first.receiver}}'
      end
    end

    # assert(!'rubocop-minitest'.kind_of?(String))
    # =>
    # refute_kind_of(String, 'rubocop-minitest')
    find_node '.send[receiver=nil][message=assert][arguments.size=1]
                    [arguments.first=.send[message=!][receiver=.send[message=kind_of?][arguments.size=1]]]' do
      group do
        replace :message, with: 'refute_kind_of'
        replace :arguments, with: '{{arguments.first.receiver.arguments.first}}, {{arguments.first.receiver.receiver}}'
      end
    end
  end
end
