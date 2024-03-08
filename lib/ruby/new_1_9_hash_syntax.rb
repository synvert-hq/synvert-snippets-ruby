# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'new_1_9_hash_syntax' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    Use ruby 1.9 new hash syntax.

    ```ruby
    { :foo => 'bar' }
    ```

    =>

    ```ruby
    { foo: 'bar' }
    ```
  EOS

  if_ruby '1.9.0'

  within_files Synvert::ALL_RUBY_FILES + Synvert::ALL_RAKE_FILES do
    # {:foo => 'bar'} => {foo: 'bar'}
    find_node %q{.hash_node .assoc_node[key=.symbol_node][key=~/\A:([^'"]+)\z/][operator = =>]} do
      replace_with "{{key.unescaped}}: {{value}}"
    end
  end
end
