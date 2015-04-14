class AddProfilePictureToUsers < ActiveRecord::Migration
  def change
    remove_attachment :users, :avatar
    add_column :users, :profilePicture, :integer
  end
end
