require 'json'

module EventHandlers
  def online_event(socket, user, token)
    user = User.find_by id: user
    if user.nil? || user.token != token
      send_error socket, 'Invalid user or token'
      return
    end

    add_client(socket, user)
  end

  def feed_event(socket, user)
    hashtags = user.hashtags.map(&:id)
    subscribe socket, hashtags

    json = {
      'event': 'feed',
      'messages': get_feed_messages(user) # MessagesController.
    }

    socket.send(JSON.generate(json))
  end

  def favourites_event(socket, user)
    # For now users on favourites tab are already subscribed to all messages
    # through the feed event.

    # hashtags = user.favourites.map(&:id)
    # subscribe socket, hashtags

    json = {
      'event': 'favourites',
      'messages': get_favourites_messages(user) # MessagesController.
    }

    socket.send(JSON.generate(json))
  end

  def hashtag_event(socket, hashtag, from)
    subscribe(socket, hashtag.id)

    json = {
      'event': 'hashtag',
      'messages': get_hashtag_messages(hashtag, from) # MessagesController.
    }

    socket.send(JSON.generate(json))
  end

  def like_event(socket, user, message)
    like = Like.create user: user, message: message
    send_error(socket, 'Invalid like') && return unless like.valid?

    json = {
      'event': 'like',
      'hashtag': message.hashtag.id,
      'message': message.id,
      'user': user.name
    }

    broadcast(JSON.generate(json), message.hashtag.id)
    send(JSON.generate(json), message.user) unless subscribed?(message.user, message.hashtag.id)
    notification_from_like(user, message) unless online?(message.user)
  end

  def dislike_event(socket, user, message)
    like = Like.find_by user: user, message: message
    send_error(socket, 'Invalid like') && return if like.nil?
    like.destroy

    json = {
      'event': 'dislike',
      'hashtag': message.hashtag.id,
      'message': message.id,
      'user': user.name
    }

    broadcast(JSON.generate(json), message.hashtag.id)
  end

  def message_event(socket, user, hashtag, content, photo_ids = [])
    message = create_message content, user.id, hashtag.id, photo_ids
    send_error(socket, 'Invalid message') && return unless message.valid?

    broadcast(JSON.generate(message.serialize), hashtag.id)
    # send_notifications_from_message(message)
    send_mentions(message)
  end

  def topic_event(socket, user, hashtag, topic, photo_id)
    photo = Photo.find_by id: photo_id

    return if topic == hashtag.topic && (photo.nil? || photo == hashtag.photo)

    hashtag.topic = topic
    hashtag.photo = photo unless photo.nil?
    hashtag.topic_updater = user
    send_error(socket, 'Invalid topic or photo') && return unless hashtag.save

    url = hashtag.photo.nil? ? '' : hashtag.photo.image.url(:cover)

    json = JSON.generate('event': 'topic',
                         'hashtag': hashtag.id,
                         'user': user.name,
                         'topic': topic,
                         'photo': url,
                         'timestamp': hashtag.timestamp)

    broadcast(json, hashtag.id)
    hashtag.users.each do |user_|
      next if subscribed?(user_, hashtag.id)
      send(json, user_)
      notification_from_topic(user_, hashtag)
    end
  end
end
