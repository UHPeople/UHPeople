class Photo < ActiveRecord::Base
  validates :user_id, presence: true

  belongs_to :user

  has_attached_file :image, styles: { medium: '300x300>', thumb: '45x45#' },
                    default_url: 'missing.png'
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/
  validates_attachment_file_name :image, matches: [/png\Z/, /jpe?g\Z/]
  validates_attachment_size :image, in: 0..10.megabytes
end
