class FeedController < ApplicationController
  def index
    @chats = current_user.hashtags.map { |tag| tag.messages.last(5) }
  end
end 