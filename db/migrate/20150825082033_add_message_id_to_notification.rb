class AddMessageIdToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :message_id, :integer
  end
end
