class SessionController < ApplicationController
  def login
    @user = User.find(params[:id])
    session[:user_id] = @user.id
    redirect_to feed_index_path
  end

  def logout
    session[:user_id] = nil
    if ENV['RAILS_ENV'] == 'production'
      redirect_to '/Shibboleth.sso/Logout'
    else
      redirect_to root_path
    end
  end

  def callback
    uid = request.env["omniauth.auth"]["uid"]
    @user = User.find_by name: uid
    if @user.nil?
	@user = User.create name: uid
	session[:user_id] = @user.id
	redirect_to edit_user_path(@user)
    else
	session[:user_id] = @user.id
	redirect_to feed_index_path
    end     
  end
end
