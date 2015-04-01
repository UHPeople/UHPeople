class ChangeProfilePictureToIntFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :profilePicture
    add_column :users, :profilePhoto, :integer
  end

  def self.down
    add_column :users, :profilePicture, :string
    remove_column :users, :profilePhoto
  end
end
