# frozen_string_literal: true

require 'securerandom'

Synvert::Rewriter.new 'rails', 'upgrade_3_2_to_4_0' do
  description <<~EOS
    It upgrades rails from 3.2 to 4.0.

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

    12. it removes `Rack::Utils.escape` in config/routes.rb.

    ```ruby
    Rack::Utils.escape('こんにちは') => 'こんにちは'
    ```

    13. it replaces match in config/routes.rb.

    ```ruby
    match "/" => "root#index"
    ```

    =>

    ```ruby
    get "/" => "root#index"
    ```

    14. it replaces instance method serialized_attributes with class method.

    ```ruby
    self.serialized_attributes
    ```

    =>

    ```ruby
    self.class.serialized_attributes
    ```

    15. it replaces `dependent: :restrict` to `dependent: :restrict_with_exception`.

    16. it removes `config.whiny_nils = true`.

    17. it replaces

    ```ruby
    link_to 'delete', post_path(post), confirm: 'Are you sure to delete post?'
    ```

    =>

    ```ruby
    link_to 'delete', post_path(post), data: { confirm: 'Are you sure to delete post?' }
    ```
  EOS

  add_snippet 'rails', 'convert_dynamic_finders'
  add_snippet 'rails', 'strong_parameters'
  add_snippet 'rails', 'convert_controller_filter_to_action'
  add_snippet 'rails', 'convert_model_lambda_scope'
  add_snippet 'rails', 'fix_4_0_deprecations'

  if_gem 'rails', { gte: '4.0.0' }

  within_file 'config/application.rb' do
    # if defined?(Bundler)
    #   Bundler.require(*Rails.groups(:assets => %w(development test)))
    # end
    # => Bundler.require(:default, Rails.env)
    with_node type: 'if', condition: { type: 'defined?', arguments: ['Bundler'] } do
      replace_with 'Bundler.require(:default, Rails.env)'
    end
  end

  within_file 'config/**/*.rb' do
    # remove config.active_record.identity_map = true
    with_node type: 'send', receiver: { type: 'send', receiver: { type: 'send', message: 'config' }, message: 'active_record' }, message: 'identity_map=' do
      remove
    end

    # remove config.whiny_nils = true
    with_node type: 'send', receiver: { type: 'send', message: 'config' }, message: 'whiny_nils=' do
      remove
    end

    # config.assets.compress = ... => config.assets.js_compressor = ...
    with_node type: 'send', receiver: { type: 'send', receiver: { type: 'send', message: 'config' }, message: 'assets' }, message: 'compress=' do
      replace_with 'config.assets.js_compressor = {{arguments}}'
    end

    # remove config.action_dispatch.best_standards_support = ...
    with_node type: 'send', receiver: { type: 'send', receiver: { type: 'send', message: 'config' }, message: 'action_dispatch' }, message: 'best_standards_support=' do
      remove
    end

    # remove config.middleware.xxx(..., ActionDispatch::BestStandardsSupport)
    with_node type: 'send', arguments: { any: 'ActionDispatch::BestStandardsSupport' } do
      remove
    end

    # ActionController::Base.page_cache_extension = ... => ActionController::Base.default_static_extension = ...
    with_node type: 'send', message: 'page_cache_extension=' do
      replace_with 'ActionController::Base.default_static_extension = {{arguments}}'
    end
  end

  within_file 'config/environments/production.rb' do
    # insert config.eager_load = true
    unless_exist_node type: 'send', message: 'eager_load=' do
      insert 'config.eager_load = true'
    end
  end

  within_file 'config/environments/development.rb' do
    # insert config.eager_load = false
    unless_exist_node type: 'send', message: 'eager_load=' do
      insert 'config.eager_load = false'
    end

    # remove config.active_record.auto_explain_threshold_in_seconds = x
    with_node type: 'send', message: 'auto_explain_threshold_in_seconds=', receiver: { type: 'send', receiver: 'config', message: 'active_record' } do
      remove
    end
  end

  within_file 'config/environments/test.rb' do
    # insert config.eager_load = false
    unless_exist_node type: 'send', message: 'eager_load=' do
      insert 'config.eager_load = false'
    end
  end

  within_file 'config/initializers/wrap_parameters.rb' do
    # remove
    # ActiveSupport.on_load(:active_record) do
    #   self.include_root_in_json = false
    # end
    with_node type: 'block', caller: { receiver: 'ActiveSupport', message: 'on_load', arguments: [:active_record] } do
      if_only_exist_node type: 'send', receiver: 'self', message: 'include_root_in_json=', arguments: [false] do
        remove
      end
    end
  end

  within_file 'config/initializers/secret_token.rb' do
    # insert Application.config.secret_key_base = '...'
    unless_exist_node type: 'send', message: 'secret_key_base=' do
      with_node type: 'send', message: 'secret_token=' do
        secret = SecureRandom.hex(64)
        insert_after "{{receiver}}.secret_key_base = \"#{secret}\""
      end
    end
  end

  within_file 'config/routes.rb' do
    # Rack::Utils.escape('こんにちは') => 'こんにちは'
    with_node type: 'send', receiver: 'Rack::Utils', message: 'escape' do
      replace_with '{{arguments}}'
    end
  end

  within_file 'config/routes.rb' do
    # match "/" => "root#index" => get "/" => "root#index"
    with_node type: 'send', message: 'match' do
      replace_with 'get {{arguments}}'
    end
  end

  within_files 'app/models/**/*.rb' do
    # self.serialized_attributes => self.class.serialized_attributes
    with_node type: 'send', receiver: 'self', message: 'serialized_attributes' do
      replace_with 'self.class.serialized_attributes'
    end
  end

  within_files 'app/models/**/*.rb' do
    # has_many :comments, dependent: :restrict => has_many :comments, dependent: restrict_with_exception
    %w(has_one has_many).each do |message|
      within_node type: 'send', receiver: nil, message: message do
        with_node type: 'pair', key: 'dependent', value: :restrict do
          replace_with 'dependent: :restrict_with_exception'
        end
      end
    end
  end

  within_files 'app/views/**/*.erb' do
    # link_to 'delete', post_path(post), confirm: 'Are you sure to delete post?'
    # =>
    # link_to 'delete', post_path(post), data: { confirm: 'Are you sure to delete post?' }
    within_node type: 'send', message: 'link_to', arguments: { last: { type: 'hash' } } do
      if node.arguments.last.has_key?(:confirm)
        hash = node.arguments.last
        other_arguments_str = node.arguments[0...-1].map(&:to_source).join(', ')
        confirm = hash.hash_value(:confirm).to_source
        other_options = hash.children.map { |pair|
          unless [:confirm, :data].include?(pair.key.to_value)
            if pair.key.type == :sym
              "#{pair.key.to_value}: #{pair.value.to_source}"
            else
              "#{pair.key.to_source} => #{pair.value.to_source}"
            end
          end
        }.compact.join(', ')
        data_options = "data: { confirm: #{confirm} }"
        replace_with "link_to #{other_arguments_str}, #{other_options}, #{data_options}"
      end
    end
  end

  todo <<~EOS
    1. Rails 4.0 no longer supports loading plugins from vendor/plugins. You must replace any plugins by extracting them to gems and adding them to your Gemfile. If you choose not to make them gems, you can move them into, say, lib/my_plugin/* and add an appropriate initializer in config/initializers/my_plugin.rb.

    2.  Make the following changes to your Gemfile.

        gem 'sass-rails', '~> 4.0.0'
        gem 'coffee-rails', '~> 4.0.0'
        gem 'uglifier', '>= 1.3.0'
  EOS
end
