require 'json'

module EventHandlers
  def like_event(user, message)
    like = Like.find_by(user_id: user.id, message: message)

    if like.nil?
      like = Like.new(user_id: user.id, message: message)
      unless like.valid?
        send_error socket, 'Invalid like'
        return
      end

      add_likenotif(message, user) #NotificationController.
      like_callback('like', message)
    else
      like.destroy

      remove_likenotif(message, user) #NotificationController.
      like_callback('dislike', message)
    end
  end

  def feed_event(user, socket)
    hashtags = user.hashtags.map(&:id)
    add_client socket, user.id, hashtags

    json = {
      'event': 'messages',
      'messages': get_feed_messages(user) #MessagesController.
    }

    socket.send(JSON.generate(json))
  end

  def favourites_event(user, socket)
    json = {
      'event': 'favourites',
      'messages': get_favourites_messages(user) #MessagesController.
    }

    socket.send(JSON.generate(json))
  end

  def message_event(user, hashtag, socket, content)
    message = create_message content, user.id, hashtag.id #MessagesController.

    unless message.valid?
      send_error socket, 'Invalid message'
      return
    end

    find_mentions(message)

    broadcast(JSON.generate(message.serialize(user)), hashtag.id)
  end

  def messages_event(user, hashtag, from, socket)
    json = {
      'event': 'messages',
      'messages': get_hashtag_messages(hashtag, from) #MessagesController.
    }

    socket.send(JSON.generate(json))
  end

  def online_event(user, hashtag, socket)
    add_client socket, user.id, hashtag.id
    broadcast(online_users(hashtag.id), hashtag.id)
  end
end
