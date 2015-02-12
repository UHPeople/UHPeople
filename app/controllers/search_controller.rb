class SearchController < ApplicationController
	before_action :set_search, only: [:index]

	def index
		@searchword = params[:search]
    @searchword = @searchword.downcase unless @searchword == nil

		@hashtag = Hashtag.new

   	@hashtags = Hashtag.where("tag like ?", "%#{@searchword}%")
   	@users = User.where("name like ?", "%#{@searchword}%")

   	@hashtags_exact = Hashtag.where("tag like ?", "#{@searchword}")
	end

	private

	def set_search
	 @search = params[:search]
	end
end	