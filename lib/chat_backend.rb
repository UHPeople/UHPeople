require 'faye/websocket'
require 'json'
require 'erb'

require_relative 'support/client.rb'
require_relative 'support/client_list.rb'

module UHPeople
  class ChatBackend
    include ClientList

    KEEPALIVE_TIME = 15

    def initialize(app)
      @app = app
      super
    end

    def call(env)
      if Faye::WebSocket.websocket? env
        ws = Faye::WebSocket.new(env, nil, ping: KEEPALIVE_TIME)

        ws.on :message do |event|
          data = JSON.parse(event.data)
          respond ws, data
        end

        ws.on :close do
          remove_client ws
        end

        ws.rack_response
      else
        env['chat.join_callback'] = proc { |user, hashtag| hashtag_callback('join', user, hashtag) }
        env['chat.leave_callback'] = proc { |user, hashtag| hashtag_callback('leave', user, hashtag) }
        env['chat.like_callback'] = proc { |event, message| like_callback(event, message) }
        env['chat.notification_callback'] = proc { |user| notification_callback(user) }

        @app.call(env)
      end
    end

    # private

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

    def save_like(user, _socket, message)
      like = Like.find_by(user_id: user.id, message: message)

      if like.nil?
        like = Like.new(user_id: user.id, message: message)
        return unless like.save
        add_likenotif(message, user)
        like_callback('like', message)
      else
        like.destroy
        remove_likenotif(message, user)
        like_callback('dislike', message)
      end
    end

    def send_error(socket, error)
      json = {
        'event': 'error',
        'content': error
      }

      socket.send(JSON.generate(json))
    end

    def graceful_find(type, id, socket)
      type.find(id)
    rescue ActiveRecord::RecordNotFound
      send_error socket, "Invalid #{type} id"
      return
    end

    def feed_event(user, socket)
      hashtags = user.hashtags.map(&:id)
      add_client socket, user.id, hashtags

      # json = { 'event': 'feed', 'user': user.id }
      # socket.send(JSON.generate(json))

      # Stolen from feed_controller
      # Needs to be refactored
      tags = user.user_hashtags.includes(hashtag: :messages).map(&:hashtag)
      messages = Message.includes(:hashtag, :user)
                 .where(hashtag: tags)
                 .order(created_at: :desc).limit(20).reverse

      json = {
        'event': 'messages',
        'messages': messages.map { |m| m.serialize(user) }
      }

      socket.send(JSON.generate(json))
    end

    def favourites_event(user, socket)
      hashtags = user.user_hashtags.includes(hashtag: :messages).favourite.map(&:hashtag)
      messages_json = []
      hashtags.each do |hashtag|
        messages = hashtag.messages.order(created_at: :desc).limit(5).reverse
        messages_json += messages.map { |message| message.serialize(user) }
      end

      json = {
        'event': 'favourites',
        'messages': messages_json
      }

      socket.send(JSON.generate(json))
    end

    def message_event(user, hashtag, socket, content)
      message = Message.create content: content,
                               hashtag_id: hashtag.id,
                               user_id: user.id

      unless message.valid?
        send_error socket, 'Invalid message'
        return
      end

      find_mentions(message)
      broadcast(JSON.generate(message.serialize(user)), hashtag.id)
    end

    def messages_event(user, hashtag, message, socket)
      messages = nil
      if message.nil?
        messages = hashtag.messages.all.order(created_at: :desc).limit(20)
      else
        messages = hashtag.messages.where("id < ? ", message.id).order(created_at: :desc).limit(20)
      end

      json = {
        'event': 'messages',
        'messages': messages.map { |m| m.serialize(user) }
      }

      socket.send(JSON.generate(json))
    end

    def online_event(user, hashtag, socket)
      add_client socket, user.id, hashtag.id
      broadcast(online_users(hashtag.id), hashtag.id)
    end

    def find_mentions(message)
      message.hashtag.users.each do |user|
        send_mention(user.id,
          message.user_id,
          message.hashtag_id,
          message) if message.content.include? "@#{user.username}"
      end
    end

    def send_mention(user, tricker, hashtag, message)
      Notification.create notification_type: 3,
                          user_id: user,
                          tricker_user_id: tricker,
                          tricker_hashtag_id: hashtag,
                          message: message

      notification_callback(user)
    end

    def add_likenotif(message, tricker_user)
      if (message.likes.count == 1 ||
          Notification.find_by_message_id_and_notification_type(message.id, 4) == nil)
        send_likenotif(message.user_id,
                     tricker_user.id,
                     message.hashtag_id,
                     message)
      else
        update_likenotif(message, tricker_user.id, true)
      end
    end

    def send_likenotif(user, tricker, hashtag, message)
      Notification.create notification_type: 4,
                          user_id: user,
                          tricker_user_id: tricker,
                          tricker_hashtag_id: hashtag,
                          message: message
      notification_callback(user)
    end

    def update_likenotif(message, tricker_user, renotify)
      notif = Notification.find_by_message_id_and_notification_type(message.id, 4)
      notif.update(tricker_user_id: tricker_user)
      if renotify == true && notif.visible == false
        notif.update(visible: true)
        notification_callback(message.user_id)
      end
    end

    def remove_likenotif(message, tricker_user)
      if (message.likes.count == 0)
        Notification.find_by_message_id_and_notification_type(message.id, 4).destroy if not nil
      else
        if Notification.find_by_message_id_and_notification_type(message.id, 4) == nil
          send_likenotif(message.user_id,
                   tricker_user.id,
                   message.hashtag_id,
                   message)
        else
          update_likenotif(message, message.likes.last.user_id, false)
        end
      end
    end


    def respond(socket, data)
      p data

      user = graceful_find(User, data['user'], socket)
      return if user.nil?

      if data['event'] == 'feed'
        feed_event(user, socket)
        return
      elsif data['event'] == 'favourites'
        favourites_event(user, socket)
        return
      elsif data['event'] == 'like'
        message = graceful_find(Message, data['message'], socket)
        return if message.nil?

        save_like(user, socket, message)
        return
      end

      hashtag = graceful_find(Hashtag, data['hashtag'], socket)
      return if hashtag.nil?

      unless user.hashtags.include? hashtag
        send_error socket, 'User not member of hashtag'
        return
      end

      if data['event'] == 'message'
        message_event(user, hashtag, socket, data['content'])
      elsif data['event'] == 'online'
        online_event(user, hashtag, socket)
        messages_event(user, hashtag, nil, socket)
      elsif data['event'] == 'messages'
        message = graceful_find(Message, data['message'], socket)
        return if message.nil?

        messages_event(user, hashtag, message, socket)
      end
    end
  end
end
