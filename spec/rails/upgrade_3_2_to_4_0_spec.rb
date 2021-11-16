# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Upgrade rails from 3.2 to 4.0' do
  let(:rewriter_name) { 'rails/upgrade_3_2_to_4_0' }
  let(:application_content) { <<~EOS }
    if defined?(Bundler)
      Bundler.require(*Rails.groups(:assets => %w(development test)))
    end
    module Synvert
      class Application < Rails::Application
        config.active_record.whitelist_attributes = true
        config.active_record.mass_assignment_sanitizer = :strict
        config.assets.compress = :uglifier
        config.middleware.insert_before(Rack::Lock, ActionDispatch::BestStandardsSupport)
      end
    end
  EOS

  let(:application_rewritten_content) { <<~EOS }
    Bundler.require(:default, Rails.env)
    module Synvert
      class Application < Rails::Application
        config.assets.js_compressor = :uglifier
      end
    end
  EOS

  let(:production_content) { <<~EOS }
    Synvert::Application.configure do
      config.cache_classes = true
      config.active_record.identity_map = true
      config.action_dispatch.best_standards_support = :builtin

      ActionController::Base.page_cache_extension = "html"
    end
  EOS

  let(:production_rewritten_content) { <<~EOS }
    Synvert::Application.configure do
      config.eager_load = true
      config.cache_classes = true

      ActionController::Base.default_static_extension = "html"
    end
  EOS

  let(:development_content) { <<~EOS }
    Synvert::Application.configure do
      config.cache_classes = false
      config.active_record.auto_explain_threshold_in_seconds = 0.5
    end
  EOS

  let(:development_rewritten_content) { <<~EOS }
    Synvert::Application.configure do
      config.eager_load = false
      config.cache_classes = false
    end
  EOS

  let(:test_content) { <<~EOS }
    Synvert::Application.configure do
      config.whiny_nils = true
      config.cache_classes = false
    end
  EOS

  let(:test_rewritten_content) { <<~EOS }
    Synvert::Application.configure do
      config.eager_load = false
      config.cache_classes = false
    end
  EOS

  let(:wrap_parameters_content) { <<~EOS }
    ActiveSupport.on_load(:action_controller) do
      wrap_parameters format: [:json]
    end
    ActiveSupport.on_load(:active_record) do
      self.include_root_in_json = false
    end
  EOS

  let(:wrap_parameters_rewritten_content) { <<~EOS }
    ActiveSupport.on_load(:action_controller) do
      wrap_parameters format: [:json]
    end
  EOS

  let(:secret_token_content) { <<~EOS }
    Synvert::Application.config.secret_token = "0447aa931d42918bfb934750bb78257088fb671186b5d1b6f9fddf126fc8a14d34f1d045cefab3900751c3da121a8dd929aec9bafe975f1cabb48232b4002e4e"
  EOS

  let(:secret_token_rewritten_content) { <<~EOS }
    Synvert::Application.config.secret_token = "0447aa931d42918bfb934750bb78257088fb671186b5d1b6f9fddf126fc8a14d34f1d045cefab3900751c3da121a8dd929aec9bafe975f1cabb48232b4002e4e"
    Synvert::Application.config.secret_key_base = "bf4f3f46924ecd9adcb6515681c78144545bba454420973a274d7021ff946b8ef043a95ca1a15a9d1b75f9fbdf85d1a3afaf22f4e3c2f3f78e24a0a188b581df"
  EOS

  let(:routes_content) { <<~EOS }
    Synvert::Application.routes.draw do
      get Rack::Utils.escape('こんにちは'), controller: 'welcome', action: 'index'
      match '/' => 'root#index'
      match 'new', to: 'episodes#new'
    end
  EOS

  let(:routes_rewritten_content) { <<~EOS }
    Synvert::Application.routes.draw do
      get 'こんにちは', controller: 'welcome', action: 'index'
      get '/' => 'root#index'
      get 'new', to: 'episodes#new'
    end
  EOS

  let(:schema_content) { <<~EOS }
    ActiveRecord::Schema.define(version: 20140211112752) do
      create_table "users", force: true do |t|
        t.integer  "account_id",               index: true
        t.string   "login"
        t.string   "email"
        t.datetime "created_at"
        t.datetime "updated_at"
        t.integer  "role",                      default: 0,     null: false
        t.boolean  "admin",                     default: false, null: false
        t.boolean  "active",                    default: false, null: false
      end
    end
  EOS

  let(:post_model_content) { <<~EOS }
    class Post < ActiveRecord::Base
      has_many :comments, dependent: :restrict

      attr_accessible :title, :description

      def serialized_attrs
        self.serialized_attributes
      end
    end
  EOS

  let(:post_model_rewritten_content) { <<~EOS }
    class Post < ActiveRecord::Base
      has_many :comments, dependent: :restrict_with_exception

      def serialized_attrs
        self.class.serialized_attributes
      end
    end
  EOS

  let(:posts_index_content) { <<~EOS }
    <% @posts.each do |post| %>
      <%= link_to "delete", post_url(post), remote: true, confirm: "Are you sure to delete a post" %>
    <% end %>
  EOS

  let(:posts_index_rewritten_content) { <<~EOS }
    <% @posts.each do |post| %>
      <%= link_to "delete", post_url(post), remote: true, data: { confirm: "Are you sure to delete a post" } %>
    <% end %>
  EOS

  let(:fake_file_paths) do
    %w[
      config/application.rb
      config/environments/production.rb
      config/environments/development.rb
      config/environments/test.rb
      config/initializers/wrap_parameters.rb
      config/initializers/secret_token.rb
      config/routes.rb
      db/schema.rb
      app/models/post.rb
      app/views/posts/index.html.erb
    ]
  end
  let(:test_contents) do
    [
      application_content,
      production_content,
      development_content,
      test_content,
      wrap_parameters_content,
      secret_token_content,
      routes_content,
      schema_content,
      post_model_content,
      posts_index_content
    ]
  end
  let(:test_rewritten_contents) do
    [
      application_rewritten_content,
      production_rewritten_content,
      development_rewritten_content,
      test_rewritten_content,
      wrap_parameters_rewritten_content,
      secret_token_rewritten_content,
      routes_rewritten_content,
      schema_content,
      post_model_rewritten_content,
      posts_index_rewritten_content
    ]
  end

  before do
    expect(SecureRandom).to receive(:hex)
      .with(64)
      .and_return(
        'bf4f3f46924ecd9adcb6515681c78144545bba454420973a274d7021ff946b8ef043a95ca1a15a9d1b75f9fbdf85d1a3afaf22f4e3c2f3f78e24a0a188b581df'
      )
    load_sub_snippets(
      %w[
        rails/strong_parameters
        rails/convert_dynamic_finders
        rails/convert_controller_filter_to_action
        rails/convert_model_lambda_scope
        rails/fix_4_0_deprecations
      ]
    )
  end

  include_examples 'convertable with multiple files'
end
