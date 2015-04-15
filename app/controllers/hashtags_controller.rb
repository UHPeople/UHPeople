class HashtagsController < ApplicationController
  before_action :require_login

  before_action :set_hashtag, only: [:show, :update, :join, :leave, :invite]
  before_action :user_has_tag, only: [:show, :update]
  before_action :topic_updater, only: [:show, :update]

  def index
    respond_to do |format|
      format.json do
        render json: 'Not logged in' && return if current_user.nil?

        tags = Hashtag.all.collect do |tag|
          { id: tag.id, tag: tag.tag }
        end

        render json: tags
      end

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
    redirect_to hashtag_path(tag: @hashtag.tag)
  end

  def leave
    current_user.hashtags.destroy(@hashtag)
    request.env['chat.leave_callback'].call(current_user, @hashtag)
    redirect_to hashtag_path(@hashtag.tag)
  end

  def update
    @hashtag.topic_updater_id = current_user.id

    unless @hashtag.update(hashtag_params)
      redirect_to hashtag_path(@hashtag.tag), notice: 'Something went wrong!'
      return
    end

    @hashtag.users.each do |user|
      Notification.create notification_type: 2,
                          user: user,
                          tricker_user: current_user,
                          tricker_hashtag: @hashtag

      request.env['chat.notification_callback'].call(user.id)
    end

    redirect_to hashtag_path(@hashtag.tag), notice: 'Topic was successfully updated.'
  end

  def create
    @hashtag = Hashtag.new tag: params[:tag]

    if @hashtag.save
      current_user.hashtags << @hashtag
      redirect_to hashtag_path(@hashtag.tag)
    end
  end

  def invite
    user = User.find_by(name: params[:user])

    if user.hashtags.include? @hashtag
      respond_to do |format|
        format.html { redirect_to hashtag_path(@hashtag), notice: 'User already a member!' }
        format.json { render status: 400 }
      end

      return
    end

    Notification.create notification_type: 1,
                        user_id: user.id,
                        tricker_user: current_user,
                        tricker_hashtag: @hashtag

    request.env['chat.notification_callback'].call(user.id)

    respond_to do |format|
      format.html { redirect_to hashtag_path(@hashtag.tag) }
      format.json { render json: { name: user.name, avatar: user.profile_picture_url } }
    end
  end

  private

  def set_hashtag
    @hashtag = Hashtag.find_by(tag: params[:tag])
    render 'errors/error' if @hashtag.nil?
  end

  def user_has_tag
    @user_has_tag = current_user.hashtags.include? @hashtag
  end

  def hashtag_params
    params.require(:hashtag).permit(:topic, :topic_updater_id, :cover_photo)
  end

  def topic_updater
    @topicker = User.find(@hashtag.topic_updater_id)
    rescue
      @topicker = nil
  end
end
