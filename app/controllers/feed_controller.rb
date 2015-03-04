class FeedController < ApplicationController
  before_action :require_login

  def index
    fav_tags = current_user.user_hashtags.where(favourite:true)
    @chats = fav_tags.map { |tag| tag.messages.last(5) }

    tags = current_user.hashtags
    @messages = Message.includes(:hashtag).all.map { |message| message if tags.include? message.hashtag }
    @messages.compact.sort_by { |message| message.timestamp }
    @messages = @messages.reverse!
  end
end 