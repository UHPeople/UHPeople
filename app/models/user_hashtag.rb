class UserHashtag < ActiveRecord::Base
  validates :user_id, :hashtag_id, presence: true

  belongs_to :user
  belongs_to :hashtag
end
