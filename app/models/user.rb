class User < ActiveRecord::Base
  validates :name, :campus, presence: true

  has_secure_token

  has_many :user_hashtags, dependent: :destroy
  has_many :hashtags, through: :user_hashtags
  has_many :messages, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :photos, dependent: :destroy
  has_many :likes, dependent: :destroy

  def unread_notifications?
    notifications.unread_count > 0
  end

  def profile_picture_url(size = :thumb)
    photo = Photo.find_by id: profilePicture
    return ActionController::Base.helpers.asset_path('missing.png') if photo.nil?

    photo.image.url(size)
  end

  def six_most_active_channels
    # replace with sql join
    non_zero_tags = user_hashtags.where(hashtag_id: messages.map(&:hashtag_id).uniq)
    non_zero_tags.sort_by { |h| messages.where(hashtag_id: h.hashtag_id).count }.reverse.first(6)
  end

  def unactive_channels
    active = six_most_active_channels.map(&:hashtag_id)
    user_hashtags.where.not(hashtag_id: active)
  end

  def last_visit(hashtag)
    timestamp = user_hashtags.find_by(hashtag_id: hashtag.id).last_visited
    timestamp ||= Time.zone.now
    timestamp.strftime('%Y-%m-%dT%H:%M:%S')
  end

  def likes?(message)
    likes.each { |like| return true if like.message == message }
    false
  end

  def favourites
    user_hashtags.favourite.map(&:hashtag)
  end
end
