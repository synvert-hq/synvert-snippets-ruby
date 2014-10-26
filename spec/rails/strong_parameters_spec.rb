require 'spec_helper'

RSpec.describe 'rails strong_parameters snippet' do
  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/rails/strong_parameters.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'with fakefs', fakefs: true do
    let(:application_content) {'
module Synvert
  class Application < Rails::Application
    config.active_record.whitelist_attributes = true
    config.active_record.mass_assignment_sanitizer = :strict
  end
end
    '}
    let(:application_rewritten_content) {'
module Synvert
  class Application < Rails::Application
  end
end
    '}
    let(:post_model_content) {'
class Post < ActiveRecord::Base
  attr_accessible :title, :description
end
    '}
    let(:post_model_rewritten_content) {'
class Post < ActiveRecord::Base
end
    '}
    let(:user_model_content) {'
class User < ActiveRecord::Base
  attr_protected :role, :admin
end
    '}
    let(:user_model_rewritten_content) {'
class User < ActiveRecord::Base
end
    '}
    let(:comment_model_content) {'
class Comment < ActiveRecord::Base
  attr_accessible *Model::MY_CONSTANT
end
    '}
    let(:comment_model_rewritten_content) {'
class Comment < ActiveRecord::Base
end
    '}
    let(:schema_content) {'
ActiveRecord::Schema.define(version: 20140211112752) do
  create_table "users", force: true do |t|
    t.string   "login"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role",                      default: 0,     null: false
    t.boolean  "admin",                     default: false, null: false
    t.index    [:email, :role]
  end
end
    '}
    let(:posts_controller_content) {'
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
    '}
    let(:posts_controller_rewritten_content) {'
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
    '}
    let(:comments_controller_content) {'
class CommentsController < ApplicationController
  def create
    @post = Post.find(params[:id])
    @post.comments.create params[:comment]
  end
end
    '}
    let(:comments_controller_rewritten_content) {'
class CommentsController < ApplicationController
  def create
    @post = Post.find(params[:id])
    @post.comments.create comment_params
  end

  def comment_params
    params.require(:comment).permit(*Model::MY_CONSTANT)
  end
end
    '}
    let(:users_controller_content) {'
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
    '}
    let(:users_controller_rewritten_content) {'
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
    params.require(:user).permit(:login, :email, :created_at, :updated_at)
  end
end
    '}

    it 'process' do
      FileUtils.mkdir_p 'config'
      FileUtils.mkdir_p 'db'
      FileUtils.mkdir_p 'app/models'
      FileUtils.mkdir_p 'app/controllers'
      File.write 'config/application.rb', application_content
      File.write 'db/schema.rb', schema_content
      File.write 'app/models/post.rb', post_model_content
      File.write 'app/models/comment.rb', comment_model_content
      File.write 'app/models/user.rb', user_model_content
      File.write 'app/controllers/posts_controller.rb', posts_controller_content
      File.write 'app/controllers/comments_controller.rb', comments_controller_content
      File.write 'app/controllers/users_controller.rb', users_controller_content
      @rewriter.process
      expect(File.read 'config/application.rb').to eq application_rewritten_content
      expect(File.read 'app/models/post.rb').to eq post_model_rewritten_content
      expect(File.read 'app/models/comment.rb').to eq comment_model_rewritten_content
      expect(File.read 'app/models/user.rb').to eq user_model_rewritten_content
      expect(File.read 'app/controllers/posts_controller.rb').to eq posts_controller_rewritten_content
      expect(File.read 'app/controllers/comments_controller.rb').to eq comments_controller_rewritten_content
      expect(File.read 'app/controllers/users_controller.rb').to eq users_controller_rewritten_content
    end
  end
end
