class Hashtag < ActiveRecord::Base
  validates :tag, presence: true, uniqueness: true,
                  format: { with: /\A[A-Za-z0-9]*\z/ }

  has_many :user_hashtags
  has_many :users, through: :user_hashtags
  has_many :messages
end
