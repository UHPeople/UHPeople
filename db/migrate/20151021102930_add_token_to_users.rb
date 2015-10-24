class AddTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :token, :string
    User.all.each { |user| user.regenerate_token }
  end
end
