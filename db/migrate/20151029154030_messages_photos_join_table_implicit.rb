class MessagesPhotosJoinTableImplicit < ActiveRecord::Migration
  def change
    drop_table :message_photos
    create_table :messages_photos, id: false do |t|
      t.belongs_to :message, index: true
      t.belongs_to :photo, index: true
    end
  end
end
