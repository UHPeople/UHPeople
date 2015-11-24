require 'tagcloud_logic'

class FeedController < ApplicationController
  before_action :require_login

  def index
    cu_hashtags = current_user.user_hashtags.includes(hashtag: :messages)
    @user_tags = cu_hashtags.downcase_sorted
    @fav_user_tags = @user_tags.map { |userhashtag| userhashtag.hashtag if userhashtag.favourite? }.compact

    @word_array = cloud_cache
    @tab = current_user.tab

    @top_hashtags = top('top_hashtags', 'hashtag_id', Hashtag)
    @top_users = top('top_users', 'user_id', User)
  end

  # private

  def top(cache_id, id, type)
    Rails.cache.fetch(cache_id, expires_in: 30.minutes) do
      ids = Message.group(id).count
      top = type.all.map { |h| [h, ids[h.id]] unless ids[h.id].nil? }
      top.compact.sort_by { |h| h[1] }.reverse.first(15)
    end
  end

  def cloud_cache
    Rails.cache.fetch('hashtag_cloud', expires_in: 30.minutes) do
      cloud = TagcloudLogic.new
      cloud.make_cloud
    end
  end
end
