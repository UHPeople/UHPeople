class User < ActiveRecord::Base
  belongs_to :user
  belongs_to :hashtag
end
