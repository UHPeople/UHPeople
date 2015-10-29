require 'json'

module EventHandlers
  def online_event(socket, user, token)
    user = User.find_by id: user
    if user.nil? or user.token != token
      send_error socket, 'Invalid user or token'
    end

    add_client(socket, user)
  end

  def feed_event(socket, user)
    hashtags = user.hashtags.map(&:id)
    subscribe socket, hashtags

    json = {
      'event': 'feed',
      'messages': get_feed_messages(user) #MessagesController.
    }

    socket.send(JSON.generate(json))
  end

  def favourites_event(socket, user)
    # For now users on favourites tab are already subscribed to all messages
    # through the feed event.

    # hashtags = user.hashtags.favourites.map(&:id)
    # subscribe socket, hashtags

    json = {
      'event': 'favourites',
      'messages': get_favourites_messages(user) #MessagesController.
    }

    socket.send(JSON.generate(json))
  end

  def hashtag_event(socket, user, hashtag, from)
    subscribe socket, hashtag.id

    json = {
      'event': 'hashtag',
      'messages': get_hashtag_messages(user, hashtag, from) #MessagesController.
    }

    socket.send(JSON.generate(json))
  end

  def like_event(socket, user, message)
    like = Like.create user: user, message: message
    unless like.valid?
      send_error socket, 'Invalid like'
      return
    end

    json = {
      'event': 'like',
      'hashtag': message.hashtag.id,
      'message': message.id
    }

    broadcast(JSON.generate(json), message.hashtag.id)
    send(JSON.generate(json), message.user) unless subscribed(message.user, message.hashtag.id)
    notification_from_like(user, message) unless online(message.user)
  end

  def dislike_event(socket, user, message)
    like = Like.find_by user: user, message: message
    if like.nil?
      send_error socket, 'Invalid like'
      return
    end

    like.destroy

    json = {
      'event': 'dislike',
      'hashtag': message.hashtag.id,
      'message': message.id
    }

    broadcast(JSON.generate(json), message.hashtag.id)
  end

  def message_event(socket, user, hashtag, content, photo_ids)
    message = create_message content, user.id, hashtag.id, photo_ids #MessagesController.

    unless message.valid?
      send_error socket, 'Invalid message'
      return
    end

    json = JSON.generate(message.serialize)
    broadcast(json, hashtag.id)

    hashtag.users.each do |u|
      unless subscribed(u, hashtag.id)
        send(json, u)
        notification_from_message(u, message)
      end
    end

    find_mentions(message).each do |id|
      user = User.find_by id: id
      unless user.nil?
        json = {
          'event': 'mention',
          'user': message.user,
          'message': message.id
        }

        send(JSON.generate(json), user)
        notification_from_mention(user, message)
      end
    end
  end
end
