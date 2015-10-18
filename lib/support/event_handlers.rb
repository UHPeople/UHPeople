require 'json'

module EventHandlers
  def like_event(user, message)
    like = Like.create user: user, message: message
    unless like.valid?
      send_error socket, 'Invalid like'
      return
    end

    add_likenotif message, user #NotificationController.
    like_callback 'like', message
  end

  def dislike_event(user, message)
    like = Like.find_by user: user, message: message
    if like.nil?
      send_error socket, 'Invalid like'
      return
    end

    like.destroy

    remove_likenotif message, user #NotificationController.
    like_callback 'dislike', message
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

  def message_event(user, hashtag, socket, content, photo_ids)
    message = create_message content, user.id, hashtag.id, photo_ids #MessagesController.

    unless message.valid?
      send_error socket, 'Invalid message'
      return
    end

    # parse photo_ids in separate
    # for each id in photo_ids
    # Message_photo.create message_id: message.id, photo_id: id

    find_mentions(message)

    broadcast(JSON.generate(message.serialize), hashtag.id)
  end

  def messages_event(user, hashtag, from, socket)
    json = {
      'event': 'messages',
      'messages': get_hashtag_messages(user, hashtag, from) #MessagesController.
    }

    socket.send(JSON.generate(json))
  end

  def online_event(user, hashtag, socket)
    add_client socket, user.id, hashtag.id
    broadcast(online_users(hashtag.id), hashtag.id)
  end
end
