class HashtagsController < ApplicationController
	before_action :set_hashtag, only: [:show]

  def show
    
    
  end  


  def create
    @hashtag = Hashtag.new(tag: params[:tag])
    if @hashtag.save
      current_user.hashtags << @hashtag
      redirect_to @hashtag
    end
  end   

	private

  def set_hashtag
     @hashtag = Hashtag.find(params[:id])
  end

  def hashtag_params
    params.require(:tag).permit(:tag)
  end
end
