class FeedController < ApplicationController
  before_action :require_login

  require 'tagcloud_logic'
  def index
    @user_tags = current_user.user_hashtags.includes(hashtag: :messages)
      .order('user_hashtags.favourite desc', 'hashtags.updated_at desc')

    fav_user_tags = @user_tags.favourite.joins(hashtag: :messages).uniq
    @chats = fav_user_tags.map { |tag| tag.hashtag.messages.last(5) }

    tags = @user_tags.map(&:hashtag)
    @messages = Message.includes(:hashtag, :user)
      .where(hashtag: tags)
      .order(created_at: :desc).limit(20)

    cloud = TagcloudLogic.new
    Rails.cache.write('hashtag_cloud', cloud.make_cloud(cloud.touch_cloud))
    @word_array = Rails.cache.read 'hashtag_cloud'
  end

end
