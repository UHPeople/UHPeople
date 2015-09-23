require 'faye/websocket'
require 'json'
require 'erb'

require_relative 'support/messages_controller.rb'
require_relative 'support/notification_controller.rb'

require_relative 'support/client.rb'
require_relative 'support/client_list.rb'

module UHPeople
  class ChatBackend
    include ClientList
    include MessagesController
    include NotificationController

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

    def like_event(user, _socket, message)
      like = Like.find_by(user_id: user.id, message: message)

      if like.nil?
        like = Like.new(user_id: user.id, message: message)
        return unless like.save

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

    def find_mentions(message)
      message.hashtag.users.each do |user|
        send_mention(user.id,
          message.user_id,
          message.hashtag_id,
          message) if message.content.include? "@#{user.username}"
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

    def graceful_find_all(socket, user_id = nil, hashtag_id = nil, message_id = nil)
      user = graceful_find(User, user_id, socket) unless user_id.nil?
      message = graceful_find(Message, message_id, socket) unless message_id.nil?
      hashtag = graceful_find(Hashtag, hashtag_id, socket) unless hashtag_id.nil?

      unless user.hashtags.include? hashtag
        send_error socket, 'User not member of hashtag'
        hashtag = nil
      end

      return user, message, hashtag
    end

    def respond(socket, data)
      p data

      if data['event'] == 'feed'
        user, hashtag, message = graceful_find_all(socket, data['user'], nil, nil)
        feed_event(user, socket) unless user.nil?
      elsif data['event'] == 'favourites'
        user, hashtag, message = graceful_find_all(socket, data['user'], nil, nil)
        favourites_event(user, socket) unless user.nil?
      elsif data['event'] == 'like'
        user, hashtag, message = graceful_find_all(socket, data['user'], nil, data['message'])
        like_event(user, socket, message) unless user.nil? or message.nil?
      elsif data['event'] == 'message'
        user, hashtag, message = graceful_find_all(socket, data['user'], data['hashtag'], nil)
        message_event(user, hashtag, socket, data['content']) unless user.nil? or hashtag.nil?
      elsif data['event'] == 'online'
        user, hashtag, message = graceful_find_all(socket, data['user'], data['hashtag'], nil)
        online_event(user, hashtag, socket) unless user.nil? or hashtag.nil?
        messages_event(user, hashtag, nil, socket) unless user.nil? or hashtag.nil?
      elsif data['event'] == 'messages'
        user, hashtag, message = graceful_find_all(socket, data['user'], data['hashtag'], data['message'])
        messages_event(user, hashtag, message, socket) unless user.nil? or hashtag.nil? or message.nil?
      end
    end
  end
end
