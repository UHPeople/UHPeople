class SessionController < ApplicationController
  before_action :require_non_production, only: :login

  def login
    @user = User.find(params[:id])
    session[:user_id] = @user.id

    if current_user.user_hashtags.count < 3
      redirect_to threehash_path, alert: 'Please add at least three intrests!'
    else
      redirect_to feed_index_path
    end
  end

  def logout
    session[:user_id] = nil
    redirect_to ((ENV['RAILS_ENV'] == 'production') ? '/Shibboleth.sso/Logout' : root_path)
  end
end
