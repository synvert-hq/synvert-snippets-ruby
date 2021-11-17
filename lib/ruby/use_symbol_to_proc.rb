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

  within_files Synvert::ALL_RUBY_FILES do
    # (1..100).each { |i| i.to_s }
    # =>
    # (1..100).each(&:to_s)
    #
    # (1..100).map { |i| i.to_s }
    # =>
    # (1..100).map(&:to_s)
    %w[each map].each do |message|
      with_node type: 'block', caller: { message: message }, arguments: { size: 1 } do
        argument_name = node.arguments.first.name.to_s
        if_only_exist_node type: 'send', receiver: argument_name, arguments: { size: 0 } do
          replace_with '{{caller}}(&:{{body.first.message}})'
        end
      end
    end
  end
end
