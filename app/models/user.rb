class User < ActiveRecord::Base
  validates :name, presence: true

  has_many :user_hashtags, dependent: :destroy
  has_many :hashtags, through: :user_hashtags
  has_many :messages, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :photos, dependent: :destroy

  def unread_notifications
    notifications.unread_count > 0
  end

  def show_user_thumbnail
    photo = Photo.find_by id: profilePicture
    if photo != nil
      @user_photo = photo.image.url(:thumb)
    else
      @user_photo = ""
    end
  end

end
