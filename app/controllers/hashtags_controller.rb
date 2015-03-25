class HashtagsController < ApplicationController
  before_action :require_login

  before_action :set_hashtag, only: [:show, :update, :join, :leave, :invite]
  before_action :user_has_tag, only: [:show, :update]
  before_action :topic_updater, only: [:show, :update]

  def index
    respond_to do |format|
      format.json { @hashtags = Hashtag.all }
      format.html { redirect_to root_path }
    end
  end

  def show
    @messages = @hashtag.messages.last(20)

    if @hashtag.topic.blank?
      @topic_button_text = 'Add topic'
    else
      @topic_button_text = 'Edit topic'
    end
  end

  def join
    current_user.hashtags << @hashtag
    request.env['chat.join_callback'].call(current_user, @hashtag)
    redirect_to @hashtag
  end

  def leave
    current_user.hashtags.destroy(@hashtag)
    request.env['chat.leave_callback'].call(current_user, @hashtag)
    redirect_to @hashtag
  end

  def update
    respond_to do |format|
      if @hashtag.update(hashtag_params)
        format.html { redirect_to :back, notice: 'Topic was successfully updated.' }
      end
    end
  end

  def create
    @hashtag = Hashtag.new tag: params[:tag]

    if @hashtag.save
      current_user.hashtags << @hashtag
      redirect_to @hashtag
    end
  end

  def invite
    user_id = User.find_by(name: params[:user]).id

    Notification.create notification_type: 1,
                        user_id: user_id,
                        tricker_user: current_user,
                        tricker_hashtag: @hashtag

    request.env['chat.notification_callback'].call(user_id)
    redirect_to @hashtag
  end

  private

  def set_hashtag
    @hashtag = Hashtag.find(params[:id])
    rescue
      redirect_to root_path
  end

  def user_has_tag
    @user_has_tag = current_user.hashtags.include? @hashtag
  end

  def hashtag_params
    params.require(:hashtag).permit(:tag, :topic, :topic_updater_id, :cover_photo)
  end

  def topic_updater
    @topicker = User.find_by id: @hashtag.topic_updater_id
  end
end
