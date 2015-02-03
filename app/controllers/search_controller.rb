class SearchController < ApplicationController
	before_action :set_search, only: [:index]

	def show
		@searchword = params[:id]

    @hashtags = Hashtag.where("tag like ?", "%#{@searchword}%")
	end

	private
	# Use callbacks to share common setup or constraints between actions.
	def set_search
	 @search = params[:search]
	end

end	