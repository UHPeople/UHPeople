class SetUserHashtagFavouriteDefault < ActiveRecord::Migration
  def change
    change_column :user_hashtags, :favourite, :boolean, null: false, default: false

    for user_hashtag in UserHashtag.all
    	user_hashtag.favourite = false unless user_hashtag.favourite
    end
  end
end
