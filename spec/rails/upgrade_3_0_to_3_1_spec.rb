# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Upgrade rails from 3.0 to 3.1' do
  let(:rewriter_name) { 'rails/upgrade_3_0_to_3_1' }
  let(:application_content) {
    '
Synvert::Application.configure do
end
  '
  }
  let(:application_rewritten_content) {
    "
Synvert::Application.configure do
  config.assets.version = '1.0'
  config.assets.enabled = true
end
  "
  }
  let(:development_content) {
    '
Synvert::Application.configure do
  config.action_view.debug_rjs = true
end
  '
  }
  let(:development_rewritten_content) {
    '
Synvert::Application.configure do
  config.assets.debug = true
  config.assets.compress = false
end
  '
  }
  let(:production_content) {
    '
Synvert::Application.configure do
end
  '
  }
  let(:production_rewritten_content) {
    '
Synvert::Application.configure do
  config.assets.digest = true
  config.assets.compile = false
  config.assets.compress = true
end
  '
  }
  let(:test_content) {
    '
Synvert::Application.configure do
end
  '
  }
  let(:test_rewritten_content) {
    '
Synvert::Application.configure do
  config.static_cache_control = "public, max-age=3600"
  config.serve_static_assets = true
end
  '
  }
  let(:wrap_parameters_rewritten_content) { <<~EOS }
    # Enable parameter wrapping for JSON. You can disable this by setting :format to an empty array.
    ActiveSupport.on_load(:action_controller) do
      wrap_parameters format: [:json]
    end

    # Disable root element in JSON by default.
    ActiveSupport.on_load(:active_record) do
      self.include_root_in_json = false
    end
    EOS

  let(:session_store_content) {
    "
Synvert::Application.config.session_store :cookie_store, key: 'somethingold'
  "
  }
  let(:session_store_rewritten_content) {
    "
Synvert::Application.config.session_store :cookie_store, key: '_synvert-session'
  "
  }
  let(:fake_file_paths) {
    %w[
      config/application.rb
      config/environments/development.rb
      config/environments/production.rb
      config/environments/test.rb
      config/initializers/session_store.rb
      config/initializers/wrap_parameters.rb
    ]
  }
  let(:test_contents) {
    [application_content, development_content, production_content, test_content, session_store_content, nil]
  }
  let(:test_rewritten_contents) {
    [
      application_rewritten_content,
      development_rewritten_content,
      production_rewritten_content,
      test_rewritten_content,
      session_store_rewritten_content,
      wrap_parameters_rewritten_content
    ]
  }

  before do
    load_sub_snippets(%w[rails/use_migrations_instance_methods])
  end

  include_examples 'convertable with multiple files'
end
