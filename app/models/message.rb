require 'rails_autolink'

class UserHashtagValidator < ActiveModel::Validator
  def validate(message)
    return if message.user.present? && message.user.hashtags.include?(message.hashtag)
    message.errors[:user] << 'User needs to be a member of hashtag'
  end
end

class Message < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper

  include ActiveModel::Validations

  belongs_to :hashtag
  belongs_to :user

  has_many :likes, dependent: :destroy

  has_and_belongs_to_many :photos

  validates :hashtag_id, :user_id, presence: true
  validates :content, length: { maximum: 256 }

  validates :photos, presence: true, if: 'content.blank?'
  validates :content, presence: true, if: 'photos.empty?'

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

  def serialize
    { 'event': 'message',
      'content': formatted_content,
      'hashtag': hashtag_id,
      'hashtag_name': hashtag.tag,
      'user': user_id,
      'id': id,
      'username': user.name,
      'timestamp': timestamp,
      'avatar': user.profile_picture_url,
      'likes': likes.map { |like| like.user.name },
      'photos': photos.map { |photo| photo.image.url(:thumb) }
    }
  end
end
