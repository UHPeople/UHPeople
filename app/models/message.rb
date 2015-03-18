require 'rails_autolink'

class UserHashtagValidator < ActiveModel::Validator
  def validate(message)
    unless UserHashtag.where(hashtag: message.hashtag, user: message.user).exists?
      message.errors[:user] << 'User needs to be a member of hashtag'
    end
  end
end

class Message < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper

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

  def scontent
    auto_link(ERB::Util.html_escape(content)) do |text|
      truncate(text, length: 200)
    end
  end

  def serialize
    json = { 'event': 'message',
             'content': scontent,
             'hashtag': hashtag_id,
             'user': user_id,
             'username': user.name,
             'timestamp': timestamp }

    JSON.generate json
  end
end
