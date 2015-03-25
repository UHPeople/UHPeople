class Photo < ActiveRecord::Base
  validates :user_id, presence: true
  validates :photo_file_name, presence: true

  belongs_to :user
end
