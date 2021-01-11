
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
    