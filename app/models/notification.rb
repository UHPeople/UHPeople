class Notification < ActiveRecord::Base
  scope :unread, -> { where visible: true }

  belongs_to :user
  belongs_to :tricker_user, class_name: 'User', foreign_key: 'tricker_user_id'
  belongs_to :tricker_hashtag, class_name: 'Hashtag', foreign_key: 'tricker_hashtag_id'

  validates :tricker_user_id, :user_id, :tricker_hashtag_id, :notification_type, presence: true

  def self.unread_count
    unread.count
  end
end
