class FrontpageController < ApplicationController
	def index
    if not current_user.nil?
      redirect_to feed_index_path
    end
	end
end

