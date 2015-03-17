class Message < ActiveRecord::Base
  belongs_to :hashtag
  belongs_to :user

  validates :content, :hashtag_id, :user_id, presence: true

  def timestamp
    created_at.strftime('%b %e, %Y %k:%M:%S')
  end

  after_save do
    hashtag.update_attribute(:updated_at, Time.now)
  end
end
