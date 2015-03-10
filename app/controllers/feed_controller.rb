class FeedController < ApplicationController
  before_action :require_login

  def index
    fav_tags = current_user.user_hashtags.where(favourite: true)
    @chats = fav_tags.map { |tag| tag.hashtag.messages.last(5) }

    tags = current_user.hashtags
    @messages = Message.includes(:hashtag).all.map { |message| message if tags.include? message.hashtag }
    @messages.compact.sort_by(&:timestamp)
    @messages = @messages.reverse!

    @tags_in_list = current_user.user_hashtags

    if params[:tab] == 'favourites'
      @feed_tab_class = ""
      @favourites_tab_class = "active"
    else
      @feed_tab_class = "active"
      @favourites_tab_class = ""
    end
  end
end
