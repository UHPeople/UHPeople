class UserHashtagValidator < ActiveModel::Validator
  def validate(message)
    unless UserHashtag.where(hashtag: message.hashtag, user: message.user).exists?
      message.errors[:user] << 'User needs to be a member of hashtag'
    end
  end
end

class Message < ActiveRecord::Base
  include ActiveModel::Validations

  belongs_to :hashtag
  belongs_to :user

  validates :content, :hashtag_id, :user_id, presence: true
  validates_with UserHashtagValidator

  def timestamp
    created_at.strftime('%b %e, %Y %k:%M:%S')
  end

  after_save do
    hashtag.update_attribute(:updated_at, Time.now)
  end
end
