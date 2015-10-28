require 'faye/websocket'
require 'json'
require 'erb'

require_relative 'support/messages_controller.rb'
require_relative 'support/notification_controller.rb'

require_relative 'support/chat_callbacks.rb'
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

        @app.call(env)
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
      id.nil? ? nil : type.find(id)
    rescue ActiveRecord::RecordNotFound
      send_error socket, "Invalid #{type}"
      nil
    end

    def graceful_find_all(socket, data)
      user = graceful_find(User, data['user'], socket)
      message = graceful_find(Message, data['message'], socket)
      hashtag = graceful_find(Hashtag, data['hashtag'], socket)

      if user.present? and hashtag.present? and !user.hashtags.include?(hashtag)
        send_error socket, 'User not member of hashtag'
        hashtag = nil
      end

      return user, hashtag, message
    end

    def respond(socket, data)
      user, hashtag, message = graceful_find_all(socket, data)

      if data['event'] != 'online' and !authenticated(socket)
        send_error socket, 'Not authenticated'
        return
      end

      if data['event'] == 'online'
        online_event(socket, user, data['token']) unless user.nil?
      elsif data['event'] == 'feed'
        feed_event(socket, user) unless user.nil?
      elsif data['event'] == 'favourites'
        favourites_event(socket, user) unless user.nil?
      elsif data['event'] == 'hashtag'
        hashtag_event(socket, user, hashtag, message) unless user.nil? or hashtag.nil?
      elsif data['event'] == 'like'
        like_event(socket, user, message) unless user.nil? or message.nil?
      elsif data['event'] == 'dislike'
        dislike_event(socket, user, message) unless user.nil? or message.nil?
      elsif data['event'] == 'message'
        message_event(socket, user, hashtag, data['content']) unless user.nil? or hashtag.nil?
      end
    end
  end
end
