class SetUpdatedAtsToHashtag < ActiveRecord::Migration
  def change
    for hashtag in Hashtag.all
      unless hashtag.messages.empty?
        time = hashtag.messages.last.created_at
        hashtag.update_attribute(:updated_at, time)
      end
    end
  end
end
