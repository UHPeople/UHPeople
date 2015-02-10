class AddTopicUpdaterIdToHashtags < ActiveRecord::Migration
  def change
    add_column :hashtags, :topic_updater_id, :integer
  end
end
