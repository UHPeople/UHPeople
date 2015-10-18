class UseNumbersForHashtagColors < ActiveRecord::Migration
  def change
    remove_column :hashtags, :color
    add_column :hashtags, :color, :integer, default: 0, null: false
    Hashtag.all.each do |hashtag|
      hashtag.update_attributes! color: rand(12)
    end
  end
end
