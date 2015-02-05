class SearchController < ApplicationController
	before_action :set_search, only: [:index]

	def index
		@searchword = params[:search]
		@hashtag = Hashtag.new
		#@hashtags = Hashtag.find(:all, :conditions => ['tag LIKE ?', "%#{@searchword}%"])
   	@hashtags = Hashtag.where("tag like ?", "%#{@searchword}%")
   	@users = User.where("name like ?", "%#{@searchword}%")
	end

	private
	# Use callbacks to share common setup or constraints between actions.
	def set_search
	 @search = params[:search]
	end

end	