# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'new_1_9_hash_syntax' do
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

  within_files Synvert::ALL_FILES do
    # {:foo => 'bar'} => {foo: 'bar'}
    find_node %q{.hash > .pair[key=.sym][key=~/\A:([^'"]+)\z/]} do
      new_key = node.key.to_source[1..-1]
      replace_with "#{new_key}: {{value}}"
    end
  end
end
