# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Upgrade rails from 4.2 to 5.0' do
  let(:rewriter_name) { 'rails/upgrade_4_2_to_5_0' }
  let(:application_content) { <<~EOS }
    module Synvert
      class Application < Rails::Application
        config.raise_in_transactional_callbacks = true
      end
    end
  EOS
  let(:application_rewritten_content) { <<~EOS }
    module Synvert
      class Application < Rails::Application
        config.load_defaults 5.0
      end
    end
  EOS
  let(:production_content) { <<~EOS }
    module Synvert
      class Application < Rails::Application
        config.static_cache_control = "public, max-age=31536000"
        config.serve_static_files = true
        config.middleware.use "Foo::Bar", foo: "bar"
      end
    end
  EOS
  let(:production_rewritten_content) { <<~EOS }
    module Synvert
      class Application < Rails::Application
        config.public_file_server.headers = { "Cache-Control" => "public, max-age=31536000" }
        config.public_file_server.enabled = true
        config.middleware.use Foo::Bar, foo: "bar"
      end
    end
  EOS
  let(:posts_controller_content) { <<~EOS }
    class PostsController < ApplicationController
      def test_load_error
        rescue MissingSourceFile
      end
    end
  EOS
  let(:posts_controller_rewritten_content) { <<~EOS }
    class PostsController < ApplicationController
      def test_load_error
        rescue LoadError
      end
    end
  EOS
  let(:new_framework_defaults_rewritten_content) { <<~EOS.strip }
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
  let(:fake_file_paths) {
    %w[
      config/application.rb
      config/environments/production.rb
      config/initializers/new_framework_defaults.rb
      app/controllers/posts_controller.rb
    ]
  }
  let(:test_contents) { [application_content, production_content, nil, posts_controller_content] }
  let(:test_rewritten_contents) {
    [
      application_rewritten_content,
      production_rewritten_content,
      new_framework_defaults_rewritten_content,
      posts_controller_rewritten_content
    ]
  }

  before do
    load_sub_snippets(
      %w[
        rails/add_active_record_migration_rails_version
        rails/convert_env_to_request_env
        rails/convert_head_response
        rails/convert_render_text_to_render_plain
        rails/convert_rails_test_request_methods_4_2_to_5_0
        rails/convert_to_response_parsed_body
        rails/add_application_record
        rails/add_application_job
        rails/add_application_mailer
        rails/convert_after_commit
        rails/convert_model_errors_add
      ]
    )
    load_helpers(%w[helpers/set_rails_load_defaults])
  end

  include_examples 'convertable with multiple files'
end
