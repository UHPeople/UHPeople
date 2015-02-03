class AddTopicToHashtags < ActiveRecord::Migration
  def change
    add_column :hashtags, :topic, :string
  end
end
