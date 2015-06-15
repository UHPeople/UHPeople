class RemoveTitleAndUnitFromUser < ActiveRecord::Migration
  change_table :users do |t|
    t.remove :title
    t.remove :unit
  end
end
