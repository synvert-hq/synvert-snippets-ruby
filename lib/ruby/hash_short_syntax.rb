# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'hash_short_syntax' do
  configure(parser: Synvert::SYNTAX_TREE_PARSER)

  description <<~EOS
    Use ruby 3.1 hash short syntax.

    ```ruby
    some_method(a: a, b: b, c: c, d: d + 4)
    ```

    =>

    ```ruby
    some_method(a:, b:, c:, d: d + 4)
    ```
  EOS

  if_ruby '3.1.0'

  within_files Synvert::ALL_RUBY_FILES + Synvert::ALL_RAKE_FILES do
    # {a: a} => {a:}
    find_node '.BareAssocHash .Assoc[key.node_type=Label][key.value="{{value.value}}:"]' do
      replace_with '{{key.value}}'
    end
  end
end
