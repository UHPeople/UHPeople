class FeedController < ApplicationController
  before_action :require_login

  def index
    fav_tags = current_user.user_hashtags.where(favourite: true)
    @chats = fav_tags.map do |tag| 
      messages = tag.hashtag.messages.last(5)
      messages unless messages.empty?
    end
    @chats.compact.sort_by { |chat| chat.last.timestamp unless chat.empty? }

    tags = current_user.hashtags
    @messages = Message.includes(:hashtag).all.map { |message| message if tags.include? message.hashtag }
    @messages.compact.sort_by(&:timestamp)
    @messages = @messages.reverse!

    @tags_in_list = current_user.user_hashtags
  end
end
