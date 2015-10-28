require 'json'

module ChatCallbacks
  def hashtag_callback(event, user, hashtag)
    json = {
      'event': event,
      'hashtag': hashtag.id,
      'username': user.name,
      'user': user.id
    }

    broadcast(JSON.generate(json), hashtag.id)
  end

  def notification_callback(notification)
    send(notification.serialize, notification.user)
  end
end
