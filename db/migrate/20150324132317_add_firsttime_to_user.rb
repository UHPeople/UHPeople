class AddFirsttimeToUser < ActiveRecord::Migration
  def change
    add_column :users, :first_time, :boolean, default:true
  end
end
