class Message < ActiveRecord::Base
  belongs_to :hashtag
  belongs_to :user

  validates :content, :hashtag_id, :user_id, presence: true

end
