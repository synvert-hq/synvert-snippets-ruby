# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert dynamic finders for rails 4' do
  let(:rewriter_name) { 'rails/convert_dynamic_finders_for_rails_4' }

  before do
    schema_content = <<~EOS
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

    FakeFS() do
      FileUtils.mkdir_p 'db'
      File.write('db/schema.rb', schema_content)
    end

    load_helpers(%w[helpers/parse_rails])
  end

  context 'model' do
    let(:fake_file_path) { 'app/models/post.rb' }
    let(:test_content) { <<~EOS }
      class Post < ActiveRecord::Base
        def active_users
          User.find_or_create_by_email_and_login(parmas)
          User.find_or_create_by_label(label)
          User.find_or_initialize_by_account_id(account_id)
          User.find_or_initialize_by_label(label)
        end
      end
    EOS

    let(:test_rewritten_content) { <<~EOS }
      class Post < ActiveRecord::Base
        def active_users
          User.find_or_create_by(parmas)
          User.find_or_create_by_label(label)
          User.find_or_initialize_by(account_id: account_id)
          User.find_or_initialize_by_label(label)
        end
      end
    EOS

    include_examples 'convertable'
  end

  context 'controller' do
    let(:fake_file_path) { 'app/controllers/users_controller.rb' }
    let(:test_content) { <<~EOS }
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
    EOS

    let(:test_rewritten_content) { <<~EOS }
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
    EOS

    include_examples 'convertable'
  end
end
