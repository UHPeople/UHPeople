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

  def notification_callback(user)
    json = { 'event': 'notification' }
    send(JSON.generate(json), user)
  end

  def like_callback(event, message)
    json = {
      'event': event,
      'hashtag': message.hashtag.id,
      'message': message.id
    }

    broadcast(JSON.generate(json), message.hashtag.id)
  end
end
