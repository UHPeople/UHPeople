class FrontpageController < ApplicationController
  def index
<<<<<<< HEAD
    @login_url = ENV['RAILS_ENV'] == "production" ? '/auth/shibboleth' : users_path
    
    if not current_user.nil?
      redirect_to feed_index_path
    end
=======
    redirect_to feed_index_path unless current_user.nil?
>>>>>>> dev
  end
end
