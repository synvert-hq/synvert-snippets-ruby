
class CommentsController < ApplicationController
  def create
    @post = Post.find(params[:id])
    @post.comments.create params[:comment]
  end
end
    