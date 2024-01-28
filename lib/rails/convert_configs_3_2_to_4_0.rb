# frozen_string_literal: true

Synvert::Rewriter.new 'rails', 'convert_configs_3_2_to_4_0' do
  configure(parser: Synvert::PARSER_PARSER)

  description <<~EOS
    It converts rails configs from 3.2 to 4.0.

    1. it removes assets group in config/application.rb.

    ```ruby
    if defined?(Bundler)
      Bundler.require(*Rails.groups(:assets => %w(development test)))
    end
    ```

    =>

    ```ruby
    Bundler.require(:default, Rails.env)
    ```

    2. it removes `config.active_record.identity_map = true` from config files.
       it removes `config.active_record.auto_explain_threshold_in_seconds = 0.5` from config files.

    3. it changes `config.assets.compress = ...` to `config.assets.js_compressor = ...`

    4. it removes `include_root_in_json` from config/initializers/wrap_parameters.rb.

    5. it inserts secret_key_base to config/initializers/secret_token.rb.

    ```ruby
    Application.config.secret_key_base = '...'
    ```

    6. it removes `config.action_dispatch.best_standards_support = ...` from config files.

    7. it inserts `config.eager_load = true` in config/environments/production.rb.

    8. it inserts `config.eager_load = false` in config/environments/development.rb.

    9. it inserts `config.eager_load = false` in config/environments/test.rb.

    10. it removes any code using `ActionDispatch::BestStandardsSupport` in config files.

    11. it replaces `ActionController::Base.page_cache_extension = ...` with `ActionController::Base.default_static_extension = ...` in config files.

    12. it removes `config.whiny_nils = true`.
  EOS

  if_gem 'rails', '>= 4.0'

  within_file 'config/application.rb' do
    # if defined?(Bundler)
    #   Bundler.require(*Rails.groups(:assets => %w(development test)))
    # end
    # => Bundler.require(:default, Rails.env)
    with_node node_type: 'if', expression: { node_type: 'defined?', arguments: ['Bundler'] } do
      replace_with 'Bundler.require(:default, Rails.env)'
    end
  end

  within_file 'config/**/*.rb' do
    # remove config.active_record.identity_map = true
    with_node node_type: 'send',
              receiver: {
                node_type: 'send',
                receiver: {
                  node_type: 'send',
                  message: 'config'
                },
                message: 'active_record'
              },
              message: 'identity_map=' do
      remove
    end

    # remove config.whiny_nils = true
    with_node node_type: 'send', receiver: { node_type: 'send', message: 'config' }, message: 'whiny_nils=' do
      remove
    end

    # config.assets.compress = ... => config.assets.js_compressor = ...
    with_node node_type: 'send',
              receiver: {
                node_type: 'send',
                receiver: {
                  node_type: 'send',
                  message: 'config'
                },
                message: 'assets'
              },
              message: 'compress=' do
      replace_with 'config.assets.js_compressor = {{arguments}}'
    end

    # remove config.action_dispatch.best_standards_support = ...
    with_node node_type: 'send',
              receiver: {
                node_type: 'send',
                receiver: {
                  node_type: 'send',
                  message: 'config'
                },
                message: 'action_dispatch'
              },
              message: 'best_standards_support=' do
      remove
    end

    # remove config.middleware.xxx(..., ActionDispatch::BestStandardsSupport)
    with_node node_type: 'send', arguments: { includes: 'ActionDispatch::BestStandardsSupport' } do
      remove
    end

    # ActionController::Base.page_cache_extension = ... => ActionController::Base.default_static_extension = ...
    with_node node_type: 'send', message: 'page_cache_extension=' do
      replace_with 'ActionController::Base.default_static_extension = {{arguments}}'
    end
  end

  within_file 'config/environments/production.rb' do
    # prepend config.eager_load = true
    unless_exist_node node_type: 'send', message: 'eager_load=' do
      prepend 'config.eager_load = true'
    end
  end

  within_file 'config/environments/development.rb' do
    # prepend config.eager_load = false
    unless_exist_node node_type: 'send', message: 'eager_load=' do
      prepend 'config.eager_load = false'
    end

    # remove config.active_record.auto_explain_threshold_in_seconds = x
    with_node node_type: 'send',
              message: 'auto_explain_threshold_in_seconds=',
              receiver: {
                node_type: 'send',
                receiver: 'config',
                message: 'active_record'
              } do
      remove
    end
  end

  within_file 'config/environments/test.rb' do
    # prepend config.eager_load = false
    unless_exist_node node_type: 'send', message: 'eager_load=' do
      prepend 'config.eager_load = false'
    end
  end

  within_file 'config/initializers/wrap_parameters.rb' do
    # remove
    # ActiveSupport.on_load(:active_record) do
    #   self.include_root_in_json = false
    # end
    with_node node_type: 'block',
              caller: { receiver: 'ActiveSupport', message: 'on_load', arguments: [:active_record] } do
      if_only_exist_node node_type: 'send', receiver: 'self', message: 'include_root_in_json=', arguments: [false] do
        remove
      end
    end
  end

  within_file 'config/initializers/secret_token.rb' do
    # insert Application.config.secret_key_base = '...'
    unless_exist_node node_type: 'send', message: 'secret_key_base=' do
      with_node node_type: 'send', message: 'secret_token=' do
        secret = SecureRandom.hex(64)
        insert_after "{{receiver}}.secret_key_base = \"#{secret}\""
      end
    end
  end
end
