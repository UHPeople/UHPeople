class SessionController < ApplicationController
  def login
    @user = User.find(params[:id])
    session[:user_id] = @user.id
    redirect_to @user
  end

  def logout
    session[:user_id] = nil
    redirect_to root_path
  end
end
