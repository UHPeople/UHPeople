class HashtagsController < ApplicationController
  before_action :require_login

  before_action :set_hashtag, only: [:show, :update, :join, :leave, :invite, :leave_and_destroy]
  before_action :user_has_tag, only: [:show, :update]
  before_action :topic_updater, only: [:show, :update]

  def index
    respond_to do |format|
      format.json do
        render json: 'Not logged in' && return if current_user.nil?

        tags = Hashtag.all.collect do |tag|
          { id: tag.id, tag: tag.tag, topic: tag.topic.nil? ? nil : tag.topic.truncate(30, separator: ' ') }
        end

        render json: tags
      end

      format.html { redirect_to root_path }
    end
  end

  def show
    @lastvisit_index = current_user_unread_messages(20)
    @lastvisit_date = current_user_last_visited if current_user.hashtags.include? @hashtag

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

    if @hashtag.users.empty?
      @hashtag.destroy
      redirect_to feed_index_path, notice: 'Channel deleted.'
    else
      request.env['chat.leave_callback'].call(current_user, @hashtag)
      redirect_to hashtag_path(@hashtag.tag)
    end
  end

  def add_multiple
    new_tags = []
    tags = params[:hashtags]
    unless tags.nil?
      tags.split(',').each do |tag|
        hashtag = Hashtag.find_by tag: tag
        hashtag = create_hashtag(tag) if hashtag.nil?

        redirect_to(feed_index_path, alert: 'Something went wrong!') &&
          return if hashtag.nil?

        new_tags << hashtag
      end
    end

    current_user.hashtags = (current_user.hashtags | new_tags) & new_tags

    if current_user.user_hashtags.count < 3
      redirect_to threehash_path, alert: 'Please add at least three intrests!'
    else
      redirect_to feed_index_path
    end
  end

  def update
    @hashtag.topic_updater_id = current_user.id

    redirect_to(hashtag_path(@hashtag.tag), notice: 'Something went wrong!') &&
      return unless @hashtag.update(hashtag_params)

    request.env['chat.topic_callback'].call(@hashtag)
    redirect_to hashtag_path(@hashtag.tag), notice: 'Topic was successfully updated.'
  end

  def create
    hashtag = Hashtag.find_by tag: params[:tag]
    hashtag = create_hashtag params[:tag] if hashtag.nil?

    redirect_to(feed_index_path, alert: 'Something went wrong!') &&
      return if hashtag.nil?

    current_user.hashtags << hashtag
    redirect_to hashtag_path(hashtag.tag)
  end

  def invite
    user = User.find_by(name: params[:user])

    if user.hashtags.include? @hashtag
      respond_to do |format|
        format.html { redirect_to hashtag_path(@hashtag), alert: 'User already a member!' }
        format.json { redirect_to feed_index_path, status: 400 }
      end
      return
    end

    request.env['chat.invite_callback'].call(user, @hashtag, current_user)

    respond_to do |format|
      format.html { redirect_to hashtag_path(@hashtag.tag) }
      format.json { render json: { name: user.name, avatar: user.profile_picture_url } }
    end
  end

  private

  def create_hashtag(tag)
    hashtag = Hashtag.create tag: tag, color: rand(12)
    hashtag.save ? hashtag : nil
  end

  def set_hashtag
    @hashtag = Hashtag.find_by(tag: params[:tag])
    render 'errors/error' if @hashtag.nil?
  end

  def user_has_tag
    @user_has_tag = current_user.hashtags.include? @hashtag
  end

  def hashtag_params
    params.require(:hashtag).permit(:topic, :topic_updater_id, :photo_id)
  end

  def topic_updater
    @topicker = User.find(@hashtag.topic_updater_id)
  rescue
    @topicker = nil
  end

  def current_user_last_visited
    hashtag = current_user.user_hashtags.find_by(hashtag_id: @hashtag.id)
    return Time.now.utc if hashtag.nil?

    hashtag.update_attribute(:last_visited, Time.now.utc) if hashtag.last_visited.nil?
    hashtag.last_visited.strftime('%Y-%m-%dT%H:%M:%S')
  end

  def current_user_unread_messages(count)
    return count unless current_user.hashtags.include? @hashtag

    curre = current_user.user_hashtags.find_by(hashtag_id: @hashtag.id)
    count -= curre.nil? || curre.unread_messages.nil? ? 0 : curre.unread_messages
    (count < 0) ? 0 : count
  end
end
