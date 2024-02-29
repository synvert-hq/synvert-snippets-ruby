# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'rails strong_parameters snippet' do
  let(:rewriter_name) { 'rails/strong_parameters' }
  before { load_helpers(%w[helpers/parse_rails]) }

  context 'config/application' do
    let(:fake_file_path) { 'config/application.rb' }
    let(:test_content) { <<~EOS }
      module Synvert
        class Application < Rails::Application
          config.active_record.whitelist_attributes = true
          config.active_record.mass_assignment_sanitizer = :strict
        end
      end
    EOS

    let(:test_rewritten_content) { <<~EOS }
      module Synvert
        class Application < Rails::Application
        end
      end
    EOS

    include_examples 'convertable'
  end

  context 'attr_protected' do
    let(:schema_content) { <<~EOS }
      ActiveRecord::Schema.define(version: 20140211112752) do
        create_table "users", force: true do |t|
          t.string   "login"
          t.string   "email"
          t.datetime "created_at"
          t.datetime "updated_at"
          t.integer  "role",                      default: 0,     null: false
          t.boolean  "admin",                     default: false, null: false
          t.index    [:email, :role], name: "index_users_on_email_and_role"
        end
      end
    EOS

    let(:user_model_content) { <<~EOS }
      class User < ActiveRecord::Base
        attr_protected :role, :admin
      end
    EOS

    let(:user_model_rewritten_content) { <<~EOS }
      class User < ActiveRecord::Base
      end
    EOS

    let(:users_controller_content) { <<~EOS }
      class UsersController < ApplicationController
        def update
          @user = User.find(params[:id])
          if @user.update_attributes params[:user]
            redirect_to user_path(@user)
          else
            render :action => :edit
          end
        end
      end
    EOS

    let(:users_controller_rewritten_content) { <<~EOS }
      class UsersController < ApplicationController
        def update
          @user = User.find(params[:id])
          if @user.update_attributes user_params
            redirect_to user_path(@user)
          else
            render :action => :edit
          end
        end

        def user_params
          params.require(:user).permit(:login, :email)
        end
      end
    EOS

    let(:fake_file_paths) { %w[db/schema.rb app/models/user.rb app/controllers/users_controller.rb] }
    let(:test_contents) { [schema_content, user_model_content, users_controller_content] }
    let(:test_rewritten_contents) { [schema_content, user_model_rewritten_content, users_controller_rewritten_content] }

    include_examples 'convertable with multiple files'
  end

  context 'attr_accessible' do
    let(:post_model_content) { <<~EOS }
      class Post < ActiveRecord::Base
        attr_accessible :title, :description
      end
    EOS

    let(:post_model_rewritten_content) { <<~EOS }
      class Post < ActiveRecord::Base
      end
    EOS

    let(:posts_controller_content) { <<~EOS }
      class PostsController < ApplicationController
        def update
          @post = Post.find(params[:id])
          if @post.update_attributes params[:post]
            redirect_to post_path(@post)
          else
            render :action => :edit
          end
        end
      end
    EOS

    let(:posts_controller_rewritten_content) { <<~EOS }
      class PostsController < ApplicationController
        def update
          @post = Post.find(params[:id])
          if @post.update_attributes post_params
            redirect_to post_path(@post)
          else
            render :action => :edit
          end
        end

        def post_params
          params.require(:post).permit(:title, :description)
        end
      end
    EOS

    let(:fake_file_paths) { %w[app/models/post.rb app/controllers/posts_controller.rb] }
    let(:test_contents) { [post_model_content, posts_controller_content] }
    let(:test_rewritten_contents) { [post_model_rewritten_content, posts_controller_rewritten_content] }

    include_examples 'convertable with multiple files'
  end

  context 'dynamic attr_accessible' do
    let(:comment_model_content) { <<~EOS }
      class Comment < ActiveRecord::Base
        attr_accessible *Model::MY_CONSTANT
      end
    EOS

    let(:comment_model_rewritten_content) { <<~EOS }
      class Comment < ActiveRecord::Base
      end
    EOS

    let(:comments_controller_content) { <<~EOS }
      class CommentsController < ApplicationController
        def create
          @post = Post.find(params[:id])
          @post.comments.create params[:comment]
        end
      end
    EOS

    let(:comments_controller_rewritten_content) { <<~EOS }
      class CommentsController < ApplicationController
        def create
          @post = Post.find(params[:id])
          @post.comments.create comment_params
        end

        def comment_params
          params.require(:comment).permit(*Model::MY_CONSTANT)
        end
      end
    EOS

    let(:fake_file_paths) { %w[app/models/comment.rb app/controllers/comments_controller.rb] }
    let(:test_contents) { [comment_model_content, comments_controller_content] }
    let(:test_rewritten_contents) { [comment_model_rewritten_content, comments_controller_rewritten_content] }

    include_examples 'convertable with multiple files'
  end
end
