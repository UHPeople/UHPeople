class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :current_user
  helper_method :split_str
  helper_method :require_login

  def current_user
    return nil if session[:user_id].nil?
    User.find(session[:user_id])
  end
  
  def split_str(txt, col = 40)
	  txt.gsub(/(.{1,#{col}})( +|$\n?)|(.{1,#{col}})/,
	    "\\1\\3\n") 
	end

  def require_login
    redirect_to root_path if current_user.nil?
  end
end
