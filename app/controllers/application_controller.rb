class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user
  before_action :set_cache_buster

  def current_user
    return nil if session[:user_id].nil?
    User.find(session[:user_id])
    rescue
      return nil
  end

  def require_login
    redirect_to root_path if current_user.nil?
  end

  def require_non_production
    redirect_to root_path if ENV['RAILS_ENV'] == 'production'
  end

  def set_cache_buster
    response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
  end
end
