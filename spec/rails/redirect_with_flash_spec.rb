require 'spec_helper'

RSpec.describe 'rails redirect with flash snippet' do

  before do
    rewriter_path = File.join(File.dirname(__FILE__), '../../lib/rails/redirect_with_flash.rb')
    @rewriter = eval(File.read(rewriter_path))
  end

  describe 'with fakefs', fakefs: true do
    let(:posts_controller_content) { '
class PostsController < ApplicationController
  def publish
    Post.find(params[:id]).publish!
    flash[:notice] = "Post published!"
    redirect_to root_path
  end
end'}

    let(:posts_controller_rewritten_content) { '
class PostsController < ApplicationController
  def publish
    Post.find(params[:id]).publish!
    redirect_to root_path, notice: "Post published!"
  end
end'}

    let(:comments_controller_content) { '
class CommentsController < ApplicationController
  def approve
    begin
      Comment.find(params[:id]).approve!
    rescue
      flash[:error] = "Could not approve comment!"
      redirect_to root_path
    end
  end
end'}

    let(:comments_controller_rewritten_content) { '
class CommentsController < ApplicationController
  def approve
    begin
      Comment.find(params[:id]).approve!
    rescue
      redirect_to root_path, flash: {error: "Could not approve comment!"}
    end
  end
end'}

    let(:unfixable_posts_controller_content) { '
class UnfixablePostsController < ApplicationController
  def publish
    Post.find(params[:id]).publish!
    flash[:notice] = "Post published!"
    some_other_code
    redirect_to root_path
  end
end'}

    let(:users_controller_content) { '
class UsersController < ApplicationController
  def activate
    User.find(params[:id]).activate!
    flash[:message] = "User activated!"
    redirect_to root_path
  end
end'}

    let(:users_controller_rewritten_content) { '
class UsersController < ApplicationController
  def activate
    User.find(params[:id]).activate!
    redirect_to root_path, flash: {message: "User activated!"}
  end
end'}

    let(:admins_controller_content) { '
class AdminsController < ApplicationController
  def list
    Admin.find(params[:id]).list!
    flash[:alert] = "Admin listed!"
    redirect_to root_path
  end
end'}

    let(:admins_controller_rewritten_content) { '
class AdminsController < ApplicationController
  def list
    Admin.find(params[:id]).list!
    redirect_to root_path, alert: "Admin listed!"
  end
end'}

    it 'process' do
      FileUtils.mkdir_p 'app/controllers'
      File.write 'app/controllers/posts_controller.rb', posts_controller_content
      File.write 'app/controllers/comments_controller.rb', comments_controller_content
      File.write 'app/controllers/unfixable_posts_controller.rb', unfixable_posts_controller_content
      File.write 'app/controllers/users_controller.rb', users_controller_content
      File.write 'app/controllers/admins_controller.rb', admins_controller_content
      @rewriter.process
      expect(File.read('app/controllers/posts_controller.rb')).to eq posts_controller_rewritten_content
      expect(File.read('app/controllers/comments_controller.rb')).to eq comments_controller_rewritten_content
      expect(File.read('app/controllers/unfixable_posts_controller.rb')).to eq unfixable_posts_controller_content
      expect(File.read('app/controllers/users_controller.rb')).to eq users_controller_rewritten_content
      expect(File.read('app/controllers/admins_controller.rb')).to eq admins_controller_rewritten_content
    end
  end
end
