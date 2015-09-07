require 'spec_helper'

RSpec.describe 'Convert dynamic finders' do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/rails/convert_dynamic_finders.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'with fakefs', fakefs: true do
    let(:schema_content) {'
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

    let(:post_model_content) {'
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
    '}
    let(:post_model_rewritten_content) {'
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
    '}
    let(:users_controller_content) {'
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
    '}
    let(:users_controller_rewritten_content) {'
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
    '}

    it 'converts' do
      FileUtils.mkdir_p 'db'
      FileUtils.mkdir_p 'app/models'
      FileUtils.mkdir_p 'app/controllers'
      File.write 'db/schema.rb', schema_content
      File.write 'app/models/post.rb', post_model_content
      File.write 'app/controllers/users_controller.rb', users_controller_content
      @rewriter.process
      expect(File.read 'app/models/post.rb').to eq post_model_rewritten_content
      expect(File.read 'app/controllers/users_controller.rb').to eq users_controller_rewritten_content
    end
  end
end
