class User < ActiveRecord::Base
  validates :name, presence: true

  has_many :user_hashtags
  has_many :hashtags, through: :user_hashtags
  has_many :messages
end
