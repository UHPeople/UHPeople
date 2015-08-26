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

  has_many :likes, dependent: :destroy

  validates :content, :hashtag_id, :user_id, presence: true
  validates_with UserHashtagValidator

  def timestamp
    created_at.strftime('%Y-%m-%dT%H:%M:%S')
  end

  after_save do
    hashtag.update_attribute(:updated_at, Time.now)
  end

  def formatted_content
    auto_link(ERB::Util.html_escape(content), html: { target: '_blank' }) do |text|
      truncate(text, length: 200)
    end
  end

  def likes_count
    if likes.count > 0
      pluralize(likes.count, 'like')
    end
  end

  def serialize
    json = { 'event': 'message',
             'content': formatted_content,
             'hashtag': hashtag_id,
             'hashtag_name': hashtag.tag,
             'user': user_id,
             'username': user.name,
             'timestamp': timestamp,
             'avatar': user.profile_picture_url}

    JSON.generate json
  end
end
