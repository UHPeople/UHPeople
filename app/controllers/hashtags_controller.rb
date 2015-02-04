class HashtagsController < ApplicationController
	before_action :set_hashtag, only: [:show]

	def show
		#@users = User.where (hashtag_id=(params[:id]))
    @members = User.joins(:hashtags).where(hashtags: {id:(params[:id])})
	end

  def create 
    @hashtag = Hashtag.new(params[:tag])
    @members = User.joins(:hashtags).where(hashtags: {id:(params[:id])})
    if @hashtag.save
      redirect_to hashtag_path @hashtag.id
    else
      render nothing: true
    end  
  end   


	private
  # Use callbacks to share common setup or constraints between actions.
  def set_hashtag
     @hashtag = Hashtag.find(params[:id])
  end
  def hashtag_params
    params.require(:hashtag).permit(:hashtag_id)
  end
end
