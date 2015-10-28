require 'json'
require 'erb'

# These two controllers shouldn't be in lib/
# They should be included in the correct controllers in app/controllers/

module NotificationController
  def notification_from_mention(user, message)
    notification = Notification.create notification_type: 3,
                        user: user,
                        tricker_user: message.user,
                        tricker_hashtag: message.hashtag,
                        message: message
  end

  def notification_from_like(user, message)
    notification = Notification.create notification_type: 4,
                        user: message.user,
                        tricker_user: user,
                        tricker_hashtag: message.hashtag,
                        message: message
  end

  def notification_from_message(user, message)
    notification = Notification.create notification_type: 5,
                        user: user,
                        tricker_user: message.user,
                        tricker_hashtag: message.hashtag,
                        message: message
  end
end
