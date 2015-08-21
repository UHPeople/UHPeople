require 'tagcloud_logic'

class FeedController < ApplicationController
  before_action :require_login

  def index
    cu_hashtags = current_user.user_hashtags.includes(hashtag: :messages)
    @user_tags = cu_hashtags.downcase_sorted

    fav_user_tags = cu_hashtags.favourite
    @chats = fav_user_tags.map { |user_hashtag| { tag: user_hashtag.hashtag, messages: user_hashtag.hashtag.messages.last(5) } }

    tags = @user_tags.map(&:hashtag)
    @messages = Message.includes(:hashtag, :user)
                .where(hashtag: tags)
                .order(created_at: :desc).limit(20)

    @word_array = cloud_cache
    @tab = current_user.tab
  end

  def cloud_cache
    Rails.cache.fetch('hashtag_cloud', expires_in: 30.minutes) do
      cloud = TagcloudLogic.new
      cloud.make_cloud
    end
  end
end
