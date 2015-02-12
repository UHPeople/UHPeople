class FeedController < ApplicationController
  def index
    if current_user.nil?
      redirect_to users_path
    else
      @chats = current_user.hashtags.map { |tag| tag.messages.last(5) }
    end
  end
end 