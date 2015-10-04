require 'json'
require 'erb'

# These two controllers shouldn't be in lib/
# They should be included in the correct controllers in app/controllers/

module NotificationController
  def send_mention(user, tricker, hashtag, message)
    Notification.create notification_type: 3,
                        user_id: user,
                        tricker_user_id: tricker,
                        tricker_hashtag_id: hashtag,
                        message: message

    notification_callback(user)
  end

  def add_likenotif(message, tricker_user)
    if (message.likes.count == 1 ||
        Notification.find_by_message_id_and_notification_type(message.id, 4) == nil)
      send_likenotif(message.user_id,
                   tricker_user.id,
                   message.hashtag_id,
                   message)
    else
      update_likenotif(message, tricker_user.id, true)
    end
  end

  def send_likenotif(user, tricker, hashtag, message)
    Notification.create notification_type: 4,
                        user_id: user,
                        tricker_user_id: tricker,
                        tricker_hashtag_id: hashtag,
                        message: message
    notification_callback(user)
  end

  def update_likenotif(message, tricker_user, renotify)
    notif = Notification.find_by_message_id_and_notification_type(message.id, 4)
    notif.update(tricker_user_id: tricker_user)
    if renotify == true && notif.visible == false
      notif.update(visible: true)
      notification_callback(message.user_id)
    end
  end

  def remove_likenotif(message, tricker_user)
    if (message.likes.count == 0)
      Notification.find_by_message_id_and_notification_type(message.id, 4).destroy if not nil
    else
      if Notification.find_by_message_id_and_notification_type(message.id, 4) == nil
        send_likenotif(message.user_id,
                 tricker_user.id,
                 message.hashtag_id,
                 message)
      else
        update_likenotif(message, message.likes.last.user_id, false)
      end
    end
  end
end
