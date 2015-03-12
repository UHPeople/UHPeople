class UserHashtag < ActiveRecord::Base
  validates :user_id, presence: true, uniqueness: { scope: :hashtag_id }
  validates :hashtag_id, presence: true

  belongs_to :user
  belongs_to :hashtag
end
