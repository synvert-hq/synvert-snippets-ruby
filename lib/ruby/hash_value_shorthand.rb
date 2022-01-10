# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'hash_value_shorthand' do
  description <<~EOS
    Values in Hash literals and keyword arguments can be omitted.

    ```ruby
    {x: x, y: y}

    foo(x: x, y: y)
    ```

    =>

    ```ruby
    {x:, y:}

    foo(x:, y:)
    ```
  EOS

  if_ruby '3.1'

  within_files Synvert::ALL_RUBY_FILES do
    with_node type: 'pair' do
      if node.key.to_source == node.value.to_source
        replace_with "{{key}}:"
      end
    end
  end
end
