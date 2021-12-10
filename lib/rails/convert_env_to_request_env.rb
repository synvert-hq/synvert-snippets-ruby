# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_env_to_request_env' do
  description <<~EOS
    It replaces env with request.env in controller files.

    ```ruby
    env["omniauth.auth"]
    ```

    =>

    ```ruby
    request.env["omniauth.auth"]
    ```
  EOS

  if_gem 'actionpack', '>= 5.0'

  within_file Synvert::RAILS_CONTROLLER_FILES do
    # env["omniauth.auth"]
    # =>
    # request.env["omniauth.auth"]
    with_node type: 'send', receiver: nil, message: 'env', arguments: { size: 0 } do
      replace :message, with: 'request.env'
    end
  end
end
