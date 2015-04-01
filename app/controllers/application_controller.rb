class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :current_user
  helper_method :split_str
  helper_method :show_user_thumbnail

  def current_user
    return nil if session[:user_id].nil?
    User.find(session[:user_id])
  end

  def require_login
    redirect_to root_path if current_user.nil?
  end

  def require_non_production
    redirect_to root_path if ENV['RAILS_ENV'] == 'production'
  end

  def show_user_thumbnail(user)
    photo = Photo.find_by id: user.profilePicture
    if photo != nil
      @user_photo = photo.image.url(:thumb)
    else
      @user_photo = ""
    end
  end
end
