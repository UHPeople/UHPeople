class Photo < ActiveRecord::Base
  validates :user_id, :image, presence: true

  belongs_to :user
  belongs_to :hashtag

  has_and_belongs_to_many :messages

  has_attached_file :image,
                    styles: {
                      cover: '320x1000^',
                      medium: '300x300>',
                      thumb: '45x45#',
                      small: '65x65#',
                      original: '640x480>'
                    },
                    convert_options: {
                      cover: '-quality 75 -strip',
                      medium: '-quality 75 -strip',
                      thumb: '-quality 75 -strip',
                      small: '-quality 75 -strip',
                      original: '-quality 75 -strip'
                    },
                    default_url: 'missing.png'

  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/i
  validates_attachment_file_name :image, matches: [/png\Z/i, /jpe?g\Z/i]
  validates_attachment_size :image, in: 0..10.megabytes
end
