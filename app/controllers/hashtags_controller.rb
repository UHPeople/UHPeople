class HashtagsController < ApplicationController
	before_action :set_hashtag, only: [:show]

	def show
		#@users = User.where (hashtag_id=(params[:id]))
    @members = User.joins(:hashtags).where(hashtags: {id:(params[:id])})
	end

  def create 
    
    @hashtag = Hashtag.new(tag: params[:tag])
    @hashtag.save
    @members = User.joins(:hashtags).where(hashtags: {id:(params[:id])})
    redirect_to hashtag_path @hashtag.id
  end   


	private
  # Use callbacks to share common setup or constraints between actions.
  def set_hashtag
     @hashtag = Hashtag.find(params[:id])
  end
  def hashtag_params
    params.require(:tag).permit(:tag)
  end
end
