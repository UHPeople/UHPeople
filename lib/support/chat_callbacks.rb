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

  def topic_callback(hashtag)
    json = {
      'event': 'topic',
      'hashtag': hashtag.id,
      'updater': hashtag.topic_updater
      'topic': hashtag.topic,
      'background': hashtag.photo_url
    }

    broadcast(JSON.generate(json), hashtag.id)

    hashtag.users.each do |user|
      notification_from_topic(user, hashtag) unless subscribed?(user, hashtag.id)
    end
  end

  def invite_callback(user, hashtag, trigger)
    json = {
      'event': 'invite',
      'hashtag': hashtag.id,
      'trigger': trigger
    }

    send(JSON.generate(json), user)
    notification_from_invite(user, hashtag, trigger) unless subscribed?(user, hashtag.id)
  end
end
