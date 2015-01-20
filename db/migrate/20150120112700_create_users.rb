class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :email
      t.string :campus
      t.string :unit
      t.string :profilePicture
      t.text :about

      t.timestamps null: false
    end
  end
end
