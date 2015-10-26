class Hashtag < ActiveRecord::Base
  validates :tag, presence: true, uniqueness: true,
                  format: { with: /\A[A-Öa-ö0-9_]*\z/ }

  has_many :user_hashtags, dependent: :destroy
  has_many :users, through: :user_hashtags
  has_many :messages, dependent: :destroy
  belongs_to :photo

  def latest_message
    messages.order('created_at desc').limit(1).first
  end

  delegate :empty?, to: :messages
end
