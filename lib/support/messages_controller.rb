require 'json'
require 'erb'

# These two controllers shouldn't be in lib/
# They should be included in the correct controllers in app/controllers/

module MessagesController
  def create_message(content, user_id, hashtag_id, photo_ids = [])
    photos = photo_ids.map { |id| Photo.find_by id: id }

    Message.create content: content,
                   hashtag_id: hashtag_id,
                   user_id: user_id,
                   photos: photos
  end

  def send_notifications_from_message(message)
    json = JSON.generate(message.serialize)
    message.hashtag.users.each do |user|
      next if subscribed?(user, message.hashtag.id)
      send(json, user)
      notification_from_message(user, message)
    end
  end

  def find_mentions(message)
    message.content.scan /@([0-9]+)/
  end

  def send_mentions(message)
    json = {
      'event': 'mention',
      'user': message.user,
      'message': message.id
    }

    find_mentions(message).each do |id|
      user = User.find_by id: id
      next if user.nil? || subscribed?(user, message.hashtag.id)

      send(JSON.generate(json), user)
      notification_from_mention(user, message)
    end
  end

  def get_feed_messages(user)
    tags = user.user_hashtags.includes(hashtag: :messages).map(&:hashtag)
    messages = Message.includes(:hashtag, :user)
               .where(hashtag: tags).order(created_at: :desc).limit(20).reverse
    messages.map(&:serialize)
  end

  def get_favourites_messages(user)
    hashtags = user.user_hashtags.includes(hashtag: :messages).favourite.map(&:hashtag)
    messages_json = []
    hashtags.each do |hashtag|
      messages = hashtag.messages.order(created_at: :desc).limit(5)
      messages_json += messages.map(&:serialize)
    end

    messages_json
  end

  def get_hashtag_messages(hashtag, from)
    messages = hashtag.messages.includes(:user, :likes)
    messages = from.nil? ? messages.all : messages.where('id < ? ', from.id)
    messages.order(created_at: :desc).limit(20).map(&:serialize)
  end
end
