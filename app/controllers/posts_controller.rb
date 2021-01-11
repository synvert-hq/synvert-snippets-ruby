
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
    