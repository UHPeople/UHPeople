class AddAttachmentCoverPhotoToHashtags < ActiveRecord::Migration
  def self.up
    change_table :hashtags do |t|
      t.attachment :cover_photo
    end
  end

  def self.down
    remove_attachment :hashtags, :cover_photo
  end
end
