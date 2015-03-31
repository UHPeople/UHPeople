class Photo < ActiveRecord::Base
  validates :user_id, presence: true

  belongs_to :user

  has_attached_file :photo, styles: { medium: '300x300>', thumb: '45x45#' },
                    default_url: 'missing.png'
  validates_attachment_content_type :photo, content_type: /\Aimage\/.*\Z/
  validates_attachment_file_name :photo, matches: [/png\Z/, /jpe?g\Z/]
  validates_attachment_size :photo, in: 0..10.megabytes
end
