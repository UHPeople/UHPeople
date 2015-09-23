require 'json'
require 'erb'

module MessagesController
  def get_feed_messages(user)
    tags = user.user_hashtags.includes(hashtag: :messages).map(&:hashtag)
    messages = Message.includes(:hashtag, :user)
       .where(hashtag: tags).order(created_at: :desc).limit(20).reverse()
    return messages.map { |m| m.serialize(user) }
  end

  def get_favourites_messages(user)
    hashtags = user.user_hashtags.includes(hashtag: :messages).favourite.map(&:hashtag)
    messages_json = []
    hashtags.each do |hashtag|
      messages = hashtag.messages.order(created_at: :desc).limit(5).reverse
      messages_json += messages.map { |message| message.serialize(user) }
    end

    return messages_json
  end

  def create_message(content, user_id, hashtag_id)
    Message.create content: content,
                   hashtag_id: hashtag_id,
                   user_id: user_id
  end

  def get_multiple_messages(hashtag, from)
    if from.nil?
      return hashtag.messages.all.order(created_at: :desc).limit(20)
    else
      return hashtag.messages.where("id < ? ", from.id).order(created_at: :desc).limit(20)
    end
  end
end
