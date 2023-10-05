# frozen_string_literal: true

Synvert::Rewriter.new 'minitest', 'refute_predicate' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    Use `refute_predicate` if expecting to test the predicate on the expected object and on applying predicate returns false.

    ```ruby
    assert(!expected.zero?)
    refute(expected.zero?)
    ```

    =>

    ```ruby
    refute_predicate(expected, :zero?)
    refute_predicate(expected, :zero?)
    ```
  EOS

  within_files Synvert::RAILS_MINITEST_FILES do
    # refute(expected.zero?)
    # =>
    # refute_predicate(expected, :zero?)
    find_node '.send[receiver=nil][message=refute][arguments.size=1]
                    [arguments.first=.send[message=zero?][arguments.size=0]]' do
      group do
        replace :message, with: 'refute_predicate'
        replace :arguments, with: '{{arguments.first.receiver}}, :zero?'
      end
    end

    # assert(!expected.zero?)
    # =>
    # refute_predicate(expected, :zero?)
    find_node '.send[receiver=nil][message=assert][arguments.size=1]
                    [arguments.first=.send[message=!][receiver=.send[message=zero?][arguments.size=0]]]' do
      group do
        replace :message, with: 'refute_predicate'
        replace :arguments, with: '{{arguments.first.receiver.receiver}}, :zero?'
      end
    end
  end
end
