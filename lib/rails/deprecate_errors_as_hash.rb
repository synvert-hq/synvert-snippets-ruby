# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'deprecate_errors_as_hash' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    It deprecates errors as hash.

    ```ruby
    book.errors[:title] << 'is not interesting enough.'
    book.errors.values
    book.errors.keys
    book.errors.messages.delete(:comments)
    ```

    =>

    ```ruby
    book.errors.add(:title, 'is not interesting enough.')
    book.errors.map(&:full_message)
    book.errors.map(&:attrobite)
    book.errors.delete(:comments)
    ```
  EOS

  if_gem 'activemodel', '>= 6.1'

  within_files Synvert::ALL_RUBY_FILES + Synvert::ALL_RAKE_FILES do
    with_node node_type: 'call_node',
              receiver: {
                node_type: 'call_node',
                receiver: { node_type: 'call_node', message: 'errors', arguments: nil },
                name: '[]',
                arguments: { node_type: 'arguments_node', arguments: { size: 1 } }
              },
              name: '<<',
              arguments: { node_type: 'arguments_node', arguments: { size: 1 } } do
      replace_with '{{receiver.receiver}}.add({{receiver.arguments.arguments.0}}, {{arguments.arguments.0}})'
    end

    with_node node_type: 'call_node',
              receiver: { node_type: 'call_node', name: 'errors', arguments: nil },
              name: 'values',
              arguments: nil do
      replace_with '{{receiver}}.map(&:message)'
    end

    with_node node_type: 'call_node',
              receiver: { node_type: 'call_node', name: 'errors', arguments: nil },
              name: 'keys',
              arguments: nil do
      replace_with '{{receiver}}.map(&:attribute)'
    end

    with_node node_type: 'call_node',
              receiver: {
                node_type: 'call_node',
                receiver: {
                  node_type: 'call_node',
                  name: 'errors',
                  arguments: nil
                },
                name: 'messages',
                arguments: nil
              },
              name: 'delete',
              arguments: { node_type: 'arguments_node', arguments: { size: 1 } } do
      replace :receiver, with: '{{receiver.receiver}}'
    end
  end
end
