require 'spec_helper'

RSpec.describe 'Convert dynamic finders' do
  let(:rewriter_name) { 'rails/convert_dynamic_finders' }

  before do
    schema_content =
      '
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
    '
    FakeFS() do
      FileUtils.mkdir_p 'db'
      File.write('db/schema.rb', schema_content)
    end
  end

  context 'model' do
    let(:fake_file_path) { 'app/models/post.rb' }
    let(:test_content) {
      '
class Post < ActiveRecord::Base
  def active_users
    User.find_all_by_email_and_active(email, true)
    User.includes(:posts).select(:email).order("created_at DESC").limit(2).find_all_by_active(true)
    User.find_all_by_label_and_active(label, true)
    User.find_by_email_and_active(email, true)
    User.find_by_label_and_active(label, true)
    User.find_last_by_email_and_active(email, true)
    User.find_last_by_label_and_active(label, true)
    User.scoped_by_email_and_active(email, true)
    User.includes(:posts).select(:email).order("created_at DESC").limit(2).scoped_by_active(true)
    User.scoped_by_label_and_active(label, true)
    User.find_by_sql(["select * from  users where email = ?", email])
    User.find_by_id(id)
    User.find_by_label(label)
    User.find_by_account_id(Account.find_by_email(account_email).id)
    User.find_or_create_by_email_and_login(parmas)
    User.find_or_create_by_label(label)
    User.find_or_initialize_by_account_id(:account_id => account_id)
    User.find_or_initialize_by_label(label)
  end

  def self.active_admins
    find_all_by_role_and_active("admin", true)
  end
end
    '
    }
    let(:test_rewritten_content) {
      '
class Post < ActiveRecord::Base
  def active_users
    User.where(email: email, active: true)
    User.includes(:posts).select(:email).order("created_at DESC").limit(2).where(active: true)
    User.find_all_by_label_and_active(label, true)
    User.find_by(email: email, active: true)
    User.find_by_label_and_active(label, true)
    User.where(email: email, active: true).last
    User.find_last_by_label_and_active(label, true)
    User.where(email: email, active: true)
    User.includes(:posts).select(:email).order("created_at DESC").limit(2).where(active: true)
    User.scoped_by_label_and_active(label, true)
    User.find_by_sql(["select * from  users where email = ?", email])
    User.find_by(id: id)
    User.find_by_label(label)
    User.find_by(account_id: Account.find_by(email: account_email).id)
    User.find_or_create_by(parmas)
    User.find_or_create_by_label(label)
    User.find_or_initialize_by(:account_id => account_id)
    User.find_or_initialize_by_label(label)
  end

  def self.active_admins
    where(role: "admin", active: true)
  end
end
    '
    }

    include_examples 'convertable'
  end

  context 'controller' do
    let(:fake_file_path) { 'app/controllers/users_controller.rb' }
    let(:test_content) {
      '
class UsersController < ApplicationController
  def new
    @user = User.find_or_initialize_by_login_and_email(params[:user][:login], params[:user][:email])
    @user = User.find_or_initialize_by_label(params[:user][:label])
  end

  def create
    @user = User.find_or_create_by_login_and_email(params[:user][:login], params[:user][:email])
    @user = User.find_or_create_by_label(params[:user][:label])
  end
end
    '
    }
    let(:test_rewritten_content) {
      '
class UsersController < ApplicationController
  def new
    @user = User.find_or_initialize_by(login: params[:user][:login], email: params[:user][:email])
    @user = User.find_or_initialize_by_label(params[:user][:label])
  end

  def create
    @user = User.find_or_create_by(login: params[:user][:login], email: params[:user][:email])
    @user = User.find_or_create_by_label(params[:user][:label])
  end
end
    '
    }

    include_examples 'convertable'
  end
end
