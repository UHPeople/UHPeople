class Like < ActiveRecord::Base
  belongs_to :user
  belongs_to :message

  validates :user_id, presence: true, uniqueness: { scope: :message }
  validates :message_id, presence: true
end
