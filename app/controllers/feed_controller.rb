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

    hashtag_ids = Message.group(:hashtag_id).count
    @top_hashtags = Hashtag.all.map { |h| [h, hashtag_ids[h.id]] unless hashtag_ids[h.id].nil? }
    @top_hashtags = @top_hashtags.compact.sort_by { |h| h[1] }.reverse

    user_ids = Message.group(:user_id).count
    @top_users = User.all.map { |h| [h, user_ids[h.id]] unless user_ids[h.id].nil? }
    @top_users = @top_users.compact.sort_by { |h| h[1] }.reverse
  end

  def cloud_cache
    Rails.cache.fetch('hashtag_cloud', expires_in: 30.minutes) do
      cloud = TagcloudLogic.new
      cloud.make_cloud
    end
  end
end
