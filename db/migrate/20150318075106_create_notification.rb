class CreateNotification < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :type, null: false
      t.integer :user_id, null: false
      t.string :tricker_user_id
      t.integer :tricker_hashtag_id
      t.boolean :visible, default:true, null:false
    end
  end
end
