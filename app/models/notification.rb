class Notification < ActiveRecord::Base
	belongs_to :user
	belongs_to :tricker_user, class_name: 'User', foreign_key: 'tricker_user_id'
	belongs_to :tricker_hashtag, class_name: 'Hashtag', foreign_key: 'tricker_hashtag_id'
end
