class UserHashtag < ActiveRecord::Base
  validates :user_id, presence: true, uniqueness: { scope: :hashtag_id }
  validates :hashtag_id, presence: true

  belongs_to :user
  belongs_to :hashtag

  scope :favourite, -> { where favourite: true }
  

  def unread_messages 
    #u.user_hashtags.last.hashtag.messages.where("created_at > ?", u.user_hashtags.last.last_visited ).count
    self.hashtag.messages.where("created_at > ?", self.last_visited).count  if self.last_visited
  end
end


