require 'tagcloud_logic'

class FeedController < ApplicationController
  before_action :require_login

  def index
    cu_hashtags = current_user.user_hashtags.includes(hashtag: :messages)
    @user_tags = cu_hashtags.downcase_sorted

    fav_user_tags = cu_hashtags.favourite
    @chats = fav_user_tags.map do |user_hashtag|
      { tag: user_hashtag.hashtag,
        messages: user_hashtag.hashtag.messages.last(5) }
    end

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
