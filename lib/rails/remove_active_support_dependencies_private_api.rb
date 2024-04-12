# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'remove_active_support_dependencies_private_api' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    It removes active support dependencies private api.

    ```ruby
    ActiveSupport::Dependencies.constantize("User")
    ActiveSupport::Dependencies.safe_constantize("User")
    ```

    =>

    ```ruby
    "User".constantize
    "User".safe_constantize
    ```
  EOS

  if_gem 'active_support', '>= 7.0'

  within_files Synvert::ALL_RUBY_FILES + Synvert::ALL_RAKE_FILES do
    with_node node_type: 'call_node',
              receiver: 'ActiveSupport::Dependencies',
              name: { in: ['constantize', 'safe_constantize'] },
              arguments: { node_type: 'arguments_node', arguments: { size: 1 } } do
      replace_with '{{arguments.arguments.0}}.{{message}}'
    end
  end
end
