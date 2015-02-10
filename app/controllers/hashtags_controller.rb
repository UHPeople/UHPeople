class HashtagsController < ApplicationController
	before_action :set_hashtag, only: [:show, :update]
  before_action :user_has_tag, only:[:show]

  def show
    @messages = @hashtag.messages.last(20)
  end

  def join
    @hashtag = Hashtag.find params[:id]
    current_user.hashtags << @hashtag
    redirect_to @hashtag
  end

  def leave
    @hashtag = Hashtag.find params[:id]
    current_user.hashtags.destroy(@hashtag)
    redirect_to :back
  end

  def update
    respond_to do |format|
      if @hashtag.update(hashtag_params)
        format.html { redirect_to :back, notice: 'Topic was successfully updated.' }
      end
    end
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

  def user_has_tag
    @user_has_tag = current_user.hashtags.include? @hashtag
  end 

  def hashtag_params
    params.require(:hashtag).permit(:tag, :topic, :topic_updater_id)
  end
end
