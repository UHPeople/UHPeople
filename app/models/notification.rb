class Notification < ActiveRecord::Base
	belongs_to :user
	has_one :tricker_user, class_name: 'User', foreign_key: 'id'
	has_one :tricker_hashtag, class_name: 'Hashtag', foreign_key: 'id'
end
