class ChangeDateFormatInUserHashtags < ActiveRecord::Migration
  def change
    remove_column :user_hashtags, :last_visited
    add_column :user_hashtags, :last_visited, :datetime
  end
end
