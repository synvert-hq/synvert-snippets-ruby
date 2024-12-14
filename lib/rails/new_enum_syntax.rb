# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'new_enum_syntax' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    New enum syntax introduced in Rails 7.0.

    ```ruby
    class Post < ApplicationRecord
      enum status: [ :draft, :published, :archived ], _prefix: true, _scopes: false
      enum category: [ :free, :premium ], _suffix: true, _default: :free
    end
    ```

    =>

    ```ruby
    class Post < ApplicationRecord
      enum :status, [ :draft, :published, :archived ], prefix: true, scopes: false
      enum :category, [ :free, :premium ], suffix: true, default: :free
    end
    ```
  EOS

  if_gem 'rails', '>= 7.0'

  within_files Synvert::RAILS_MODEL_FILES do
    with_node node_type: 'call_node',
              receiver: nil,
              name: 'enum',
              arguments: {
                node_type: 'arguments_node',
                arguments: {
                  size: 1,
                  first: {
                    node_type: 'keyword_hash_node',
                    elements: {
                      first: {
                        node_type: 'assoc_node',
                        value: { node_type: 'array_node' }
                      }
                    }
                  }
                }
              } do
      replace 'arguments.arguments.0.elements.0',
              with: ":{{arguments.arguments.0.elements.0.key.unescaped}}, {{arguments.arguments.0.elements.0.value}}"
    end

    with_node node_type: 'call_node',
              receiver: nil,
              name: 'enum',
              arguments: {
                node_type: 'arguments_node',
                arguments: {
                  size: 1,
                  last: {
                    node_type: 'keyword_hash_node',
                  }
                }
              } do
      goto_node 'arguments.arguments.-1' do
        with_node node_type: 'assoc_node', key: /\A_/ do
          replace 'key.value', with: node.key.value[1..-1]
        end
      end
    end
  end
end
