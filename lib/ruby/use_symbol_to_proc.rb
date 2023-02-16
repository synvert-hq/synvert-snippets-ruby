# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'use_symbol_to_proc' do
  description <<~EOS
    It uses &: (short for symbol to proc)

    ```ruby
    (1..100).each { |i| i.to_s }
    (1..100).map { |i| i.to_s }
    ```

    =>

    ```ruby
    (1..100).each(&:to_s)
    (1..100).map(&:to_s)
    ```
  EOS

  within_files Synvert::ALL_FILES do
    # (1..100).each { |i| i.to_s }
    # =>
    # (1..100).each(&:to_s)
    #
    # (1..100).map { |i| i.to_s }
    # =>
    # (1..100).map(&:to_s)
    find_node '.block[caller=.send[message in (each map)]]
                     [arguments.size=1]
                     [body.size=1]
                     [body.first=.send[arguments.size=0]]
                     [body.first.receiver="{{arguments.first}}"]' do
      replace_with '{{caller}}(&:{{body.first.message}})'
    end
  end
end
