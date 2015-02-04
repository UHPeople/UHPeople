class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :content
      t.integer :user_id
      t.integer :hashtag_id

      t.timestamps null: false
    end
  end
end
