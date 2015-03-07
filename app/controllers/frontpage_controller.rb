class FrontpageController < ApplicationController
  def index
    redirect_to feed_index_path unless current_user.nil?
  end
end
