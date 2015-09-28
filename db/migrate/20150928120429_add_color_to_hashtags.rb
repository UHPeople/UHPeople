class AddColorToHashtags < ActiveRecord::Migration

  def change
    colors = ['#ED4634', '#EA4963', '#9E42B0', '#673AB7', '#3F51B5',
      '#2996F3', '#39A9F4', '#4EBDD4', '#419688',
      '#52AF50', '#8BC34A', '#CDDC39', '#FFEB3B',
      '#F9C132', '#F49731', '#EE5330', '#795548', '#9E9E9E', '#607D8B'
    ]
    add_column :hashtags, :color, :string
    Hashtag.all.each do |hashtag|
      hashtag.update_attributes! color: colors.sample
    end
  end
end
