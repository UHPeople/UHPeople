require 'tagcloud_logic'

class FeedController < ApplicationController
  before_action :require_login

  def index
    cu_hashtags = current_user.user_hashtags.includes(hashtag: :messages)
    @user_tags = cu_hashtags.downcase_sorted

    fav_user_tags = cu_hashtags.favourite
    @chats = fav_user_tags.map do |user_hashtag|
      {
        tag: user_hashtag.hashtag,
        messages: user_hashtag.hashtag.messages.last(5)
      }
    end

    tags = @user_tags.map(&:hashtag)
    @messages = Message.includes(:hashtag, :user)
                .where(hashtag: tags)
                .order(created_at: :desc).limit(20)

    @word_array = cloud_cache
    @tab = current_user.tab

    @top_hashtags = top('hashtag_id', Hashtag)
    @top_users = top('user_id', User)
    @top_custom_hashtags = top('hashtag_id', Hashtag, [1, 2, 3])
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
