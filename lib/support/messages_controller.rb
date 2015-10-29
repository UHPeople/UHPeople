require 'json'
require 'erb'

# These two controllers shouldn't be in lib/
# They should be included in the correct controllers in app/controllers/

module MessagesController
  def create_message(content, user_id, hashtag_id, photo_ids = '')
    photos = photo_ids.split(',').map { |id| Photo.find_by(id: id) }
    Message.create content: content,
                   hashtag_id: hashtag_id,
                   user_id: user_id,
                   photos: photos
  end

  def find_mentions(message)
    message.content.scan /@([0-9]+)/
  end

  def get_feed_messages(user)
    tags = user.user_hashtags.includes(hashtag: :messages).map(&:hashtag)
    messages = Message.includes(:hashtag, :user)
       .where(hashtag: tags).order(created_at: :desc).limit(20).reverse
    return messages.map { |m| m.serialize(user) }
  end

  def get_favourites_messages(user)
    hashtags = user.user_hashtags.includes(hashtag: :messages).favourite.map(&:hashtag)
    messages_json = []
    hashtags.each do |hashtag|
      messages = hashtag.messages.order(created_at: :desc).limit(5)
      messages_json += messages.map { |message| message.serialize(user) }
    end

    return messages_json
  end

  def get_hashtag_messages(user, hashtag, from)
    messages = hashtag.messages.includes(:user, :likes)
    messages = from.nil? ? messages.all : messages.where("id < ? ", from.id)
    messages.order(created_at: :desc).limit(20).map { |m| m.serialize(user) }
  end
end
