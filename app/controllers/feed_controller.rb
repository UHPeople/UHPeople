require 'tagcloud_logic'

class FeedController < ApplicationController
  before_action :require_login

  def index
    cu_hashtags = current_user.user_hashtags.includes(hashtag: :messages)
    @user_tags = cu_hashtags.downcase_sorted
    @fav_user_tags = cu_hashtags.favourite.map(&:hashtag)

    @word_array = cloud_cache
    @tab = current_user.tab

    @top_hashtags = top('hashtag_id', Hashtag)
    @top_users = top('user_id', User)
    @top_custom_hashtags = top('hashtag_id', Hashtag, [])
  end

  def top(id, type, custom_ids = nil)
    ids = nil
    if custom_ids.nil?
      ids = Message.group(id).count
    else
      ids = Message.where('hashtag_id in (?)', custom_ids).group(id).count
    end

    top = type.all.map { |h| [h, ids[h.id]] unless ids[h.id].nil? }
    return top.compact.sort_by { |h| h[1] }.reverse.first(15)
  end

  def cloud_cache
    Rails.cache.fetch('hashtag_cloud', expires_in: 30.minutes) do
      cloud = TagcloudLogic.new
      cloud.make_cloud
    end
  end
end
