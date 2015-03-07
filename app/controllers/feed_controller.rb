class FeedController < ApplicationController
  before_action :require_login

  def index
    tags = current_user.hashtags
    @chats = tags.map { |tag| tag.messages.last(5) }

    @messages = Message.includes(:hashtag).all.map { |message| message if tags.include? message.hashtag }
    @messages.compact.sort_by(&:timestamp)
    @messages = @messages.reverse!
  end
end
