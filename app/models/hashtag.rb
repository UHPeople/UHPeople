class Hashtag < ActiveRecord::Base
  validates :tag, presence: true, uniqueness: true

  has_many :user_hashtags
  has_many :users, through: :user_hashtags
end
