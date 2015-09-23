require 'faye/websocket'
require 'json'
require 'erb'

require_relative 'support/messages_controller.rb'
require_relative 'support/notification_controller.rb'

require_relative 'support/callbacks.rb'
require_relative 'support/event_handlers.rb'

require_relative 'support/client.rb'
require_relative 'support/client_list.rb'

module UHPeople
  class ChatBackend
    include ClientList
    include MessagesController
    include NotificationController
    include ChatCallbacks
    include EventHandlers

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
