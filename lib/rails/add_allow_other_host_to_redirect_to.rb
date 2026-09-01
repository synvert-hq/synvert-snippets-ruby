# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'add_allow_other_host_to_redirect_to' do
  configure(parser: Synvert::PRISM_PARSER)

  description <<~EOS
    It allows redirect_to calls to redirect to another host in Rails 7.

    ```ruby
    redirect_to callback_url
    redirect_to callback_url, status: :see_other
    ```

    =>

    ```ruby
    redirect_to callback_url, allow_other_host: true
    redirect_to callback_url, status: :see_other, allow_other_host: true
    ```
  EOS

  if_gem 'actionpack', '>= 7.0'

  within_files Synvert::RAILS_CONTROLLER_FILES do
    with_node node_type: 'call_node',
              receiver: nil,
              name: 'redirect_to',
              arguments: {
                node_type: 'arguments_node',
                arguments: { last: { allow_other_host_value: nil } }
              } do
      insert 'allow_other_host: true', to: 'arguments', at: 'end', and_comma: true
    end
  end
end
