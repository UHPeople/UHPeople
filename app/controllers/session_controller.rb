class SessionController < ApplicationController
  before_action :require_non_production, only: :login

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
    uid = request.env['omniauth.auth']['uid']
    @user = User.find_by username: uid

    if @user.nil?
      name = request.env['omniauth.auth']['info']['name'].force_encoding('utf-8')
      mail = request.env['omniauth.auth']['info']['mail']

      @user = User.create username: uid, name: name, email: mail
      session[:user_id] = @user.id

      redirect_to edit_user_path(@user)
    else
      session[:user_id] = @user.id
      redirect_to feed_index_path
    end
  end
end
