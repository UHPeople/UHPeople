class Hashtag < ActiveRecord::Base
  validates :tag, presence: true, uniqueness: true

  has_many :users
end
