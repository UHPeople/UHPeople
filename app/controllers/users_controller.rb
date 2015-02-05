class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :login]

  def index
    @users = User.all
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  private

  def set_user
     @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :title, :email, :campus, :unit, :about)
  end
end
