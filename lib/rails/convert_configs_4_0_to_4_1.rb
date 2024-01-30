# frozen_string_literal: true

require 'securerandom'

Synvert::Rewriter.new 'rails', 'convert_configs_4_0_to_4_1' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It converts rails configs from 4.0 to 4.1.

    1. config/secrets.yml
        Create a secrets.yml file in your config folder
        Copy the existing secret_key_base from the secret_token.rb initializer to secrets.yml under the production section.
        Remove the secret_token.rb initializer

    2. add config/initializers/cookies_serializer.rb
  EOS

  secrets_content = <<~EOS
    development:
      secret_key_base: #{SecureRandom.hex(64)}

    test:
      secret_key_base: #{SecureRandom.hex(64)}

    # Do not keep production secrets in the repository,
    # instead read values from the environment.
    production:
      secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
  EOS

  if_gem 'rails', '~> 4.1.0'

  add_file 'config/secrets.yml', secrets_content

  remove_file 'config/initializers/secret_token.rb'

  add_file 'config/initializers/cookies_serializer.rb',
           'Rails.application.config.action_dispatch.cookies_serializer = :json'
end
