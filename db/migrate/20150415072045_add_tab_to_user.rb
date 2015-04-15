class AddTabToUser < ActiveRecord::Migration
  def change
    add_column :users, :tab, :integer, default: 0
  end
end
