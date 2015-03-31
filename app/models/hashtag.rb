class Hashtag < ActiveRecord::Base
  validates :tag, presence: true, uniqueness: true,
                  format: { with: /\A[A-Za-z0-9]*\z/ }

  has_many :user_hashtags, dependent: :destroy
  has_many :users, through: :user_hashtags
  has_many :messages, dependent: :destroy

  has_attached_file :cover_photo, styles: { medium: '300x320>' },
                                  default_url: 'missing.png'
  validates_attachment_content_type :cover_photo, content_type: /\Aimage\/.*\Z/
  validates_attachment_file_name :cover_photo, matches: [/png\Z/, /jpe?g\Z/]
  validates_attachment_size :cover_photo, in: 0..10.megabytes
end
