class Hashtag < ActiveRecord::Base
  has_many :users
end
