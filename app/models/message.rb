class Message < ActiveRecord::Base
  belongs_to :hashtag
  belongs_to :user
end
