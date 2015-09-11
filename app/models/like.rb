class Like < ActiveRecord::Base

  belongs_to :user
  belongs_to :message

  validates :user_id, :message_id, presence: true

end
