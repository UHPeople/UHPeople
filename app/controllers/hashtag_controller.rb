class HashtagController < ApplicationController


	def show
		@users = User.all 
	end

	private
  # Use callbacks to share common setup or constraints between actions.
  def set_hashtag
     @hashtag = Hashtag.find(params[:id])
  end
end