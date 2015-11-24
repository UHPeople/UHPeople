class Hashtag < ActiveRecord::Base
  validates :tag, presence: true, uniqueness: true,
                  format: { with: /\A[A-Öa-ö0-9_]*\z/ }

  has_many :user_hashtags, dependent: :destroy
  has_many :users, through: :user_hashtags
  has_many :messages, dependent: :destroy

  belongs_to :photo
  belongs_to :topic_updater, class_name: 'User', foreign_key: 'topic_updater_id'

  delegate :empty?, to: :messages

  def latest_message
    messages.order('created_at desc').limit(1).first
  end

  def photo_url(size = :cover)
    return ActionController::Base.helpers.asset_path('missing.png') if photo.nil?
    photo.image.url(size)
  end

  # NOTE: Hashtag is updated on new messages. This should use something else.
  def timestamp
    updated_at.strftime('%Y-%m-%dT%H:%M:%S')
  end
end
