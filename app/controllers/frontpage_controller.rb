class FrontpageController < ApplicationController
  def index
    unless current_user.nil?
      redirect_to feed_index_path
   end
  end
end
