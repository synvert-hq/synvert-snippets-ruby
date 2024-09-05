# frozen_string_literal: true

Synvert::Rewriter.new 'rails_best_practices', 'use_scope_access' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    It converts Foo to Bar

    ```ruby
    Foo
    ```

    =>

    ```ruby
    Bar
    ```
  EOS

  within_files '**/*.rb' do
    with_node type: 'const', to_source: 'Foo' do
      replace_with 'Bar'
    end
  end
end
