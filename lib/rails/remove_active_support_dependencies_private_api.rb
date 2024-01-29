# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'remove_active_support_dependencies_private_api' do
  configure(parser: Synvert::PARSER_PARSER)

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
    find_node '.send[receiver=ActiveSupport::Dependencies][message IN (constantize safe_constantize)][arguments.size=1][arguments.0="User"]' do
      replace_with '{{arguments.0}}.{{message}}'
    end
  end
end
