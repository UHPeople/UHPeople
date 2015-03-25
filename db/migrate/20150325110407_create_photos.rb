class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.integer :user_id
      t.string :photo_file_name
      t.string :photo_content_type
      t.integer :photo_file_size
      t.string :photo_text

      t.timestamps null: false
    end
  end
end
