# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'rails redirect with flash snippet' do
  let(:rewriter_name) { 'rails/redirect_with_flash' }

  context 'uses shorter syntax for :notice' do
    let(:fake_file_path) { 'app/controllers/posts_controller.rb' }
    let(:test_content) {
      '
class PostsController < ApplicationController
  def publish
    Post.find(params[:id]).publish!
    flash[:notice] = "Post published!"
    redirect_to root_path
  end
end'
    }
    let(:test_rewritten_content) {
      '
class PostsController < ApplicationController
  def publish
    Post.find(params[:id]).publish!
    redirect_to root_path, notice: "Post published!"
  end
end'
    }

    include_examples 'convertable'
  end

  context 'uses longer syntax for :error' do
    let(:fake_file_path) { 'app/controllers/comments_controller.rb' }
    let(:test_content) {
      '
class CommentsController < ApplicationController
  def approve
    begin
      Comment.find(params[:id]).approve!
    rescue
      flash[:error] = "Could not approve comment!"
      redirect_to root_path
    end
  end
end'
    }
    let(:test_rewritten_content) {
      '
class CommentsController < ApplicationController
  def approve
    begin
      Comment.find(params[:id]).approve!
    rescue
      redirect_to root_path, flash: {error: "Could not approve comment!"}
    end
  end
end'
    }

    include_examples 'convertable'
  end

  context 'does not rewrite if flash and redirect are not adjacent' do
    let(:fake_file_path) { 'app/controllers/unfixable_posts_controller.rb' }
    let(:test_content) {
      '
class UnfixablePostsController < ApplicationController
  def publish
    Post.find(params[:id]).publish!
    flash[:notice] = "Post published!"
    some_other_code
    redirect_to root_path
  end
end'
    }
    let(:test_rewritten_content) { test_content }

    include_examples 'convertable'
  end

  context 'uses longer syntax for :message' do
    let(:fake_file_path) { 'app/controllers/users_controller.rb' }
    let(:test_content) {
      '
class UsersController < ApplicationController
  def activate
    User.find(params[:id]).activate!
    flash[:message] = "User activated!"
    redirect_to root_path
  end
end'
    }
    let(:test_rewritten_content) {
      '
class UsersController < ApplicationController
  def activate
    User.find(params[:id]).activate!
    redirect_to root_path, flash: {message: "User activated!"}
  end
end'
    }
    include_examples 'convertable'
  end

  context 'uses shorter syntax for :alert' do
    let(:fake_file_path) { 'app/controllers/admins_controller.rb' }
    let(:test_content) {
      '
class AdminsController < ApplicationController
  def list
    Admin.find(params[:id]).list!
    flash[:alert] = "Admin listed!"
    redirect_to root_path
  end
end'
    }
    let(:test_rewritten_content) {
      '
class AdminsController < ApplicationController
  def list
    Admin.find(params[:id]).list!
    redirect_to root_path, alert: "Admin listed!"
  end
end'
    }

    include_examples 'convertable'
  end
end
