class CreateUserHashtags < ActiveRecord::Migration
  def change
    create_table :user_hashtags do |t|
    	t.integer :user_id
    	t.integer :hashtag_id

    	t.timestamps null: false
    end
    remove_column :hashtags, :user_id
  end
end
