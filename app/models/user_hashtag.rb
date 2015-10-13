class UserHashtag < ActiveRecord::Base
  validates :user_id, presence: true, uniqueness: { scope: :hashtag_id }
  validates :hashtag_id, presence: true

  belongs_to :user
  belongs_to :hashtag

  scope :favourite, -> { where(favourite: true) }
  scope :downcase_sorted, -> {
    includes(:hashtag).sort_by { |h| [h.favourite ? 0 : 1, h.hashtag.tag.downcase] }
  }

  def unread_messages
    return hashtag.messages.count if last_visited.nil?
    return 0 if last_visited < updated_at
    hashtag.messages.where('created_at > ?', last_visited).count
  end
end
