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
  has_many :message_photos, dependent: :destroy
  has_many :photos, through: :message_photos

  validates :content, :hashtag_id, :user_id, presence: true
  validates_with UserHashtagValidator

  def timestamp
    created_at.strftime('%Y-%m-%dT%H:%M:%S')
  end

  after_save do
    hashtag.update_attribute(:updated_at, Time.now.utc)
  end

  def formatted_content
    auto_link(ERB::Util.html_escape(content), html: { target: '_blank' }) do |text|
      truncate(text, length: 200)
    end
  end

  def likes_count
    pluralize(likes.count, 'like') if likes.count > 0
  end

  def user_likes(current_user)
    if current_user.nil?
      false
    else
      likes.exists? user_id: current_user.id
    end
  end

  def likers
    Like.includes(:user).where(message_id: self.id)
  end

  def serialize(current_user = nil)
    { 'event': 'message',
      'content': formatted_content,
      'hashtag': hashtag_id,
      'hashtag_name': hashtag.tag,
      'user': user_id,
      'id': id,
      'username': user.name,
      'timestamp': timestamp,
      'avatar': user.profile_picture_url,
      'likes': likes.count,
      'current_user_likes': user_likes(current_user)
    }
  end
end
