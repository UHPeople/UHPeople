class User < ActiveRecord::Base
  validates :name, presence: true

  has_many :user_hashtags, dependent: :destroy
  has_many :hashtags, through: :user_hashtags
  has_many :messages, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :photos, dependent: :destroy

  def unread_notifications?
    notifications.unread_count > 0
  end

  def profile_picture_url(size = :thumb)
    photo = Photo.find_by id: profilePicture
    return ActionController::Base.helpers.asset_path('missing.png') if photo.nil?

    photo.image.url(size)
  end

  def six_most_active_channels
    # 2 * On^2?
    # returns user_hashtag
    non_zero_tags = user_hashtags.where(hashtag_id: messages.map(&:hashtag_id).uniq)
    non_zero_tags.sort_by{|h| messages.where(hashtag_id:h.hashtag_id).count}.reverse.first 6
  end

  def unactive_channels
    six_channels = six_most_active_channels
    user_hashtags.where.not(hashtag_id: six_channels.map(&:hashtag_id))
  end

  def last_visit(hashtag)
    timestamp = user_hashtags.find_by(hashtag_id: hashtag.id).last_visited
    timestamp.nil? ? nil : timestamp.strftime('%Y-%m-%dT%H:%M:%S')
  end
end
