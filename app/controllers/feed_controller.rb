require 'tagcloud_logic'

class FeedController < ApplicationController
  before_action :require_login
  
  def index
    @user_tags = current_user.user_hashtags.includes(hashtag: :messages)
                 .order('user_hashtags.favourite desc', 'hashtags.updated_at desc')

    fav_user_tags = @user_tags.favourite.joins(hashtag: :messages).uniq
    @chats = fav_user_tags.map { |tag| tag.hashtag.messages.last(5) }

    tags = @user_tags.map(&:hashtag)
    @messages = Message.includes(:hashtag, :user)
                .where(hashtag: tags)
                .order(created_at: :desc).limit(20)

    @word_array = cloud_cache
  end

  def cloud_cache
    Rails.cache.fetch('hashtag_cloud', expires_in: 30.minutes) do
      cloud = TagcloudLogic.new
      cloud.make_cloud(cloud.touch_cloud)
    end
  end
end
