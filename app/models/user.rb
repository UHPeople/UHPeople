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
    self.user_hashtags.sort_by{|h| self.messages.where(hashtag_id:h.hashtag_id).count}.reverse.first 6
  end
end
