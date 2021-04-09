# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'upgrade_4_2_to_5_0' do
  description <<~EOS
    It upgrades rails 4.2 to 5.0

    1. it replaces `config.static_cache_control = ...` with `config.public_file_server.headers = ...` in config files.

    2. it replaces `config.serve_static_files = ...` with `config.public_file_server.enabled = ...` in config files.

    3. it replaces `middleware.use "Foo::Bar"` with `middleware.use Foo::Bar` in config files.

    4. it replaces `MissingSourceFile` with `LoadError`.

    5. it adds config/initializers/new_framework_defaults.rb.

    6. it removes `raise_in_transactional_callbacks=` in config/application.rb.
  EOS

  add_snippet 'rails', 'add_active_record_migration_rails_version'
  add_snippet 'rails', 'convert_head_response'
  add_snippet 'rails', 'convert_render_text_to_render_plain'
  add_snippet 'rails', 'convert_rails_test_request_methods_4_2_to_5_0'
  add_snippet 'rails', 'add_application_record'
  add_snippet 'rails', 'add_application_job'
  add_snippet 'rails', 'convert_after_commit'
  add_snippet 'rails', 'convert_model_errors_add'
  add_snippet 'rails', 'convert_to_redirect_back'

  if_gem 'rails', '>= 5.0'

  within_file 'config/application.rb' do
    # remove config.raise_in_transactional_callbacks = true
    with_node type: 'send', message: 'raise_in_transactional_callbacks=' do
      remove
    end
  end

  within_files 'config/environments/*.rb' do
    # config.static_cache_control = 'public, max-age=31536000'
    # =>
    # config.public_file_server.headers = { "Cache-Control" => 'public, max-age=31536000' }
    with_node type: 'send', message: 'static_cache_control=' do
      replace_with '{{receiver}}.public_file_server.headers = { "Cache-Control" => {{arguments}} }'
    end

    # config.serve_static_files = true
    # =>
    # config.public_file_server.enabled = true
    with_node type: 'send', message: 'serve_static_files=' do
      replace_with '{{receiver}}.public_file_server.enabled = {{arguments}}'
    end

    # config.middleware.use "Foo::Bar"
    # =>
    # config.middleware.use Foo::Bar
    with_node type: 'send',
              receiver: {
                type: 'send',
                receiver: 'config',
                message: 'middleware'
              },
              message: 'use',
              arguments: {
                first: {
                  type: 'str'
                }
              } do
      arguments_source = node.arguments.map(&:to_source)
      arguments_source[0] = node.arguments.first.to_value
      replace_with "{{receiver}}.{{message}} #{arguments_source.join(', ')}"
    end
  end

  within_files '**/*.rb' do
    # MissingSourceFile
    # =>
    # LoadError
    with_node type: 'const', to_source: 'MissingSourceFile' do
      replace_with 'LoadError'
    end
  end

  new_code = <<~EOS
    # Be sure to restart your server when you modify this file.
    #
    # This file contains migration options to ease your Rails 5.0 upgrade.
    #
    # Read the Guide for Upgrading Ruby on Rails for more info on each option.

    # Enable per-form CSRF tokens. Previous versions had false.
    Rails.application.config.action_controller.per_form_csrf_tokens = true

    # Enable origin-checking CSRF mitigation. Previous versions had false.
    Rails.application.config.action_controller.forgery_protection_origin_check = true

    # Make Ruby 2.4 preserve the timezone of the receiver when calling `to_time`.
    # Previous versions had false.
    ActiveSupport.to_time_preserves_timezone = true

    # Require `belongs_to` associations by default. Previous versions had false.
    Rails.application.config.active_record.belongs_to_required_by_default = true

    # Do not halt callback chains when a callback returns false. Previous versions had true.
    ActiveSupport.halt_callback_chains_on_return_false = false

    # Configure SSL options to enable HSTS with subdomains. Previous versions had false.
    Rails.application.config.ssl_options = { hsts: { subdomains: true } }
  EOS
  add_file 'config/initializers/new_framework_defaults.rb', new_code.strip
end
