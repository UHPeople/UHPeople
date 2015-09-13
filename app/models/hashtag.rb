class Hashtag < ActiveRecord::Base
  validates :tag, presence: true, uniqueness: true,
                  format: { with: /\A[A-Öa-ö0-9_]*\z/ }

  has_many :user_hashtags, dependent: :destroy
  has_many :users, through: :user_hashtags
  has_many :messages, dependent: :destroy

  has_attached_file :cover_photo,
                    styles: {
                      original: '320x1000^'
                    },
                    convert_options: {
                      original: '-quality 75 -strip'
                    },
                    default_url: 'missing.png'

  validates_attachment_content_type :cover_photo, content_type: /\Aimage\/.*\Z/i
  validates_attachment_file_name :cover_photo, matches: [/png\Z/i, /jpe?g\Z/i]
  validates_attachment_size :cover_photo, in: 0..10.megabytes

  def latest_message
    messages.order('created_at desc').first
  end

  delegate :empty?, to: :messages
end
