class AddFavouriteToUserHashtags < ActiveRecord::Migration
  def change
    add_column :user_hashtags, :favourite, :boolean
  end
end
