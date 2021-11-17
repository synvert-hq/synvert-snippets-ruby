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

  within_files Synvert::ALL_RUBY_FILES do
    # {:foo => 'bar'} => {foo: 'bar'}
    within_node type: 'hash' do
      with_node type: 'pair' do
        if :sym == node.key.type && node.key.to_source =~ /\A:([^'"]+)\z/
          new_key = node.key.to_source[1..-1]
          replace_with "#{new_key}: {{value}}"
        end
      end
    end
  end
end
