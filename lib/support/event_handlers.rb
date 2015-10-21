require 'json'

module EventHandlers
  def feed_event(user, socket)
    hashtags = user.hashtags.map(&:id)
    add_client socket, user.id, hashtags

    json = {
      'event': 'feed',
      'messages': get_feed_messages(user) #MessagesController.
    }

    socket.send(JSON.generate(json))
  end

  def favourites_event(user, socket)
    # For now users on favourites tab are already subscribed to all messages
    # through the feed event.

    # hashtags = user.hashtags.favourites.map(&:id)
    # add_client socket, user.id, hashtags

    json = {
      'event': 'favourites',
      'messages': get_favourites_messages(user) #MessagesController.
    }

    socket.send(JSON.generate(json))
  end

  def hashtag_event(user, hashtag, from, socket)
    json = {
      'event': 'hashtag',
      'messages': get_hashtag_messages(user, hashtag, from) #MessagesController.
    }

    socket.send(JSON.generate(json))
  end

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

  def message_event(user, hashtag, socket, content)
    message = create_message content, user.id, hashtag.id #MessagesController.

    unless message.valid?
      send_error socket, 'Invalid message'
      return
    end

    find_mentions(message)

    broadcast(JSON.generate(message.serialize), hashtag.id)
  end

  # def online_event(user, hashtag, socket)
  #   add_client socket, user.id, hashtag.id
  #   broadcast(online_users(hashtag.id), hashtag.id)
  # end
end
