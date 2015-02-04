class HashtagsController < ApplicationController
	before_action :set_hashtag, only: [:show]

	def show

	end

	private

  def set_hashtag
     @hashtag = Hashtag.find(params[:id])
  end

  def hashtag_params
    params.require(:hashtag).permit(:tag)
  end
end
