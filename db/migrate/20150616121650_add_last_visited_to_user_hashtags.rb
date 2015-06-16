class AddLastVisitedToUserHashtags < ActiveRecord::Migration
  def change
    add_column :user_hashtags, :last_visited, :Time
  end
end
