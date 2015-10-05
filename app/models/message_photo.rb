class MessagePhoto < ActiveRecord::Base
  validates :message_id, presence: true
  validates :photo_id, presence: true

  belongs_to :message
  belongs_to :photo
end
