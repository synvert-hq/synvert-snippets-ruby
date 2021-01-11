# encoding: utf-8

require 'spec_helper'

RSpec.describe 'Upgrade rails from 3.2 to 4.0' do
  let(:rewriter_name) { 'rails/upgrade_3_2_to_4_0' }
  let(:application_content) { '
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
  '}
  let(:application_rewritten_content) { '
Bundler.require(:default, Rails.env)
module Synvert
  class Application < Rails::Application
    config.assets.js_compressor = :uglifier
  end
end
  '}
  let(:production_content) { '
Synvert::Application.configure do
  config.cache_classes = true
  config.active_record.identity_map = true
  config.action_dispatch.best_standards_support = :builtin

  ActionController::Base.page_cache_extension = "html"
end
  '}
  let(:production_rewritten_content) { '
Synvert::Application.configure do
  config.eager_load = true
  config.cache_classes = true

  ActionController::Base.default_static_extension = "html"
end
  '}
  let(:development_content) { '
Synvert::Application.configure do
  config.cache_classes = false
  config.active_record.auto_explain_threshold_in_seconds = 0.5
end
  '}
  let(:development_rewritten_content) { '
Synvert::Application.configure do
  config.eager_load = false
  config.cache_classes = false
end
  '}
  let(:test_content) { '
Synvert::Application.configure do
  config.whiny_nils = true
  config.cache_classes = false
end
  '}
  let(:test_rewritten_content) { '
Synvert::Application.configure do
  config.eager_load = false
  config.cache_classes = false
end
  '}
  let(:wrap_parameters_content) { '
ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json]
end
ActiveSupport.on_load(:active_record) do
  self.include_root_in_json = false
end
  '}
  let(:wrap_parameters_rewritten_content) { '
ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json]
end
  '}
  let(:secret_token_content) { '
Synvert::Application.config.secret_token = "0447aa931d42918bfb934750bb78257088fb671186b5d1b6f9fddf126fc8a14d34f1d045cefab3900751c3da121a8dd929aec9bafe975f1cabb48232b4002e4e"
  '}
  let(:secret_token_rewritten_content) { '
Synvert::Application.config.secret_token = "0447aa931d42918bfb934750bb78257088fb671186b5d1b6f9fddf126fc8a14d34f1d045cefab3900751c3da121a8dd929aec9bafe975f1cabb48232b4002e4e"
Synvert::Application.config.secret_key_base = "bf4f3f46924ecd9adcb6515681c78144545bba454420973a274d7021ff946b8ef043a95ca1a15a9d1b75f9fbdf85d1a3afaf22f4e3c2f3f78e24a0a188b581df"
  '}
  let(:routes_content) { "
Synvert::Application.routes.draw do
  get Rack::Utils.escape('こんにちは'), controller: 'welcome', action: 'index'
  match '/' => 'root#index'
  match 'new', to: 'episodes#new'
end
  "}
  let(:routes_rewritten_content) { "
Synvert::Application.routes.draw do
  get 'こんにちは', controller: 'welcome', action: 'index'
  get '/' => 'root#index'
  get 'new', to: 'episodes#new'
end
  "}
  let(:migration_content) { "
class RenamePeopleToUsers < ActiveRecord::Migration
  def change
    change_table :posts do |t|
      t.rename :user_id, :account_id
      t.rename_index :user_id, :account_id
    end
  end
end
  "}
  let(:migration_rewritten_content) { "
class RenamePeopleToUsers < ActiveRecord::Migration
  def change
    change_table :posts do |t|
      t.rename :user_id, :account_id
    end
  end
end
  "}
  let(:schema_content) { '
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
  '}
  let(:post_model_content) { '
class Post < ActiveRecord::Base
  has_many :comments, dependent: :restrict
  scope :active, where(active: true)
  scope :published, Proc.new { where(published: true) }
  scope :by_user, proc { |user_id| where(user_id: user_id) }

  default_scope order("updated_at DESC")
  default_scope { order("created_at DESC") }

  attr_accessible :title, :description

  def serialized_attrs
    self.serialized_attributes
  end

  def active_users_by_email(email)
    User.find_all_by_email_and_active(email, true)
  end

  def active_user_emails
    User.includes(:posts).select(:email).order("created_at DESC").limit(2).find_all_by_active(true)
  end

  def active_users_by_label(label)
    User.find_all_by_label_and_active(label, true)
  end

  def first_active_user_by_email(email)
    User.find_by_email_and_active(email, true)
  end

  def first_active_user_by_label(label)
    User.find_by_label_and_active(label, true)
  end

  def last_active_user_by_email(email)
    User.find_last_by_email_and_active(email, true)
  end

  def last_active_user_by_label(label)
    User.find_last_by_label_and_active(label, true)
  end

  def scoped_active_user_by_email(email)
    User.scoped_by_email_and_active(email, true)
  end

  def scoped_active_user_emails
    User.includes(:posts).select(:email).order("created_at DESC").limit(2).scoped_by_active(true)
  end

  def scoped_active_user_by_label(label)
    User.scoped_by_label_and_active(email, true)
  end
end
  '}
  let(:post_model_rewritten_content) { '
class Post < ActiveRecord::Base
  has_many :comments, dependent: :restrict_with_exception
  scope :active, -> { where(active: true) }
  scope :published, -> { where(published: true) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }

  default_scope -> { order("updated_at DESC") }
  default_scope -> { order("created_at DESC") }

  def serialized_attrs
    self.class.serialized_attributes
  end

  def active_users_by_email(email)
    User.where(email: email, active: true)
  end

  def active_user_emails
    User.includes(:posts).select(:email).order("created_at DESC").limit(2).where(active: true)
  end

  def active_users_by_label(label)
    User.find_all_by_label_and_active(label, true)
  end

  def first_active_user_by_email(email)
    User.find_by(email: email, active: true)
  end

  def first_active_user_by_label(label)
    User.find_by_label_and_active(label, true)
  end

  def last_active_user_by_email(email)
    User.where(email: email, active: true).last
  end

  def last_active_user_by_label(label)
    User.find_last_by_label_and_active(label, true)
  end

  def scoped_active_user_by_email(email)
    User.where(email: email, active: true)
  end

  def scoped_active_user_emails
    User.includes(:posts).select(:email).order("created_at DESC").limit(2).where(active: true)
  end

  def scoped_active_user_by_label(label)
    User.scoped_by_label_and_active(email, true)
  end
end
  '}
  let(:users_controller_content) { '
class UsersController < ApplicationController
  def new
    @user = User.find_or_initialize_by_login_and_email(params[:user][:login], params[:user][:email])
  end

  def new
    @user = User.find_or_initialize_by_label_and_email(params[:user][:label], params[:user][:email])
  end

  def create
    @user = User.find_or_create_by_login_and_email(params[:user][:login], params[:user][:email])
    @user = User.find_or_create_by_label_and_email(params[:user][:label], params[:user][:email])
  end
end
  '}
  let(:users_controller_rewritten_content) { '
class UsersController < ApplicationController
  def new
    @user = User.find_or_initialize_by(login: params[:user][:login], email: params[:user][:email])
  end

  def new
    @user = User.find_or_initialize_by_label_and_email(params[:user][:label], params[:user][:email])
  end

  def create
    @user = User.find_or_create_by(login: params[:user][:login], email: params[:user][:email])
    @user = User.find_or_create_by_label_and_email(params[:user][:label], params[:user][:email])
  end
end
  '}
  let(:posts_controller_content) { '
class PostsController < ApplicationController
  before_filter :load_post
  skip_filter :load_post

  def update
    if @post.update_attributes params[:post]
      redirect_to post_path(@post)
    else
      render :action => :edit
    end
  end

  def load_post
    @post = Post.find(params[:id])
  end
end
  '}
  let(:posts_controller_rewritten_content) { '
class PostsController < ApplicationController
  before_action :load_post
  skip_action_callback :load_post

  def update
    if @post.update_attributes post_params
      redirect_to post_path(@post)
    else
      render :action => :edit
    end
  end

  def load_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :description)
  end
end
  '}
  let(:posts_index_content) { '
<% @posts.each do |post| %>
  <%= link_to "delete", post_url(post), remote: true, confirm: "Are you sure to delete a post" %>
<% end %>
  '}
  let(:posts_index_rewritten_content) { '
<% @posts.each do |post| %>
  <%= link_to "delete", post_url(post), remote: true, data: { confirm: "Are you sure to delete a post" } %>
<% end %>
  '}
  let(:post_test_content) { '
require "test_helper"

class PostTest < ActiveRecord::TestCase
end
  '}
  let(:post_test_rewritten_content) { '
require "test_helper"

class PostTest < ActiveSupport::TestCase
end
  '}
  let(:test_helper_content) { '
class ActiveSupport::TestCase
  def constants
    [ActionController::Integration, ActionController::IntegrationTest, ActionController::PerformanceTest, ActionController::AbstractRequest,
    ActionController::Request, ActionController::AbstractResponse, ActionController::Response, ActionController::Routing]
  end
end
  '}
  let(:test_helper_rewritten_content) { '
class ActiveSupport::TestCase
  def constants
    [ActionDispatch::Integration, ActionDispatch::IntegrationTest, ActionDispatch::PerformanceTest, ActionDispatch::Request,
    ActionDispatch::Request, ActionDispatch::Response, ActionDispatch::Response, ActionDispatch::Routing]
  end
end
  '}
  let(:fake_file_paths) { %w[config/application.rb config/environments/production.rb config/environments/development.rb config/environments/test.rb
    config/initializers/wrap_parameters.rb config/initializers/secret_token.rb config/routes.rb db/migrate/20140101000000_change_posts.rb db/schema.rb
    app/models/post.rb app/controllers/users_controller.rb app/controllers/posts_controller.rb app/views/posts/index.html.erb test/unit/post_test.rb test/test_helper.rb] }
  let(:test_contents) { [application_content, production_content, development_content, test_content, wrap_parameters_content, secret_token_content,
    routes_content, migration_content, schema_content, post_model_content, users_controller_content, posts_controller_content, posts_index_content,
    post_test_content, test_helper_content] }
  let(:test_rewritten_contents) { [application_rewritten_content, production_rewritten_content, development_rewritten_content, test_rewritten_content, wrap_parameters_rewritten_content, secret_token_rewritten_content,
    routes_rewritten_content, migration_rewritten_content, schema_content, post_model_rewritten_content, users_controller_rewritten_content, posts_controller_rewritten_content, posts_index_rewritten_content,
    post_test_rewritten_content, test_helper_rewritten_content] }

  before do
    expect(SecureRandom).to receive(:hex).with(64).and_return('bf4f3f46924ecd9adcb6515681c78144545bba454420973a274d7021ff946b8ef043a95ca1a15a9d1b75f9fbdf85d1a3afaf22f4e3c2f3f78e24a0a188b581df')
    load_sub_snippets(%w[rails/strong_parameters rails/convert_dynamic_finders])
  end

  include_examples 'convertable with multiple files'
end
