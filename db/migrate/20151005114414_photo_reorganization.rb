class PhotoReorganization < ActiveRecord::Migration
  def change
    create_table :message_photos do |t|
      t.integer :message_id
      t.integer :photo_id

      t.timestamps null: false
    end

    add_column :hashtags, :photo_id, :integer
    remove_attachment :hashtags, :cover_photo
  end
end
