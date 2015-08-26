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
        env['chat.notification_callback'] = proc { |user| notification_callback(user) }

        @app.call(env)
      end
    end

    # private

    def hashtag_callback(event, user, hashtag)
      json = { 'event': event, 'hashtag': hashtag.id, 'username': user.name, 'user': user.id }
      broadcast(JSON.generate(json), hashtag.id)
    end

    def notification_callback(user)
      json = { 'event': 'notification' }
      send(JSON.generate(json), user)
    end

    def send_error(socket, error)
      json = { 'event': 'error', 'content': error }
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

      json = { 'event': 'feed', 'user': user.id }
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
      broadcast(message.serialize, hashtag.id)
    end

    def online_event(user, hashtag, socket)
      add_client socket, user.id, hashtag.id
      broadcast(online_users(hashtag.id), hashtag.id)
    end

    def find_mentions(message)
      message.hashtag.users.each do |user|
        send_mention(user.id, message.user_id,
          message.hashtag_id, message) if message.content.include? "@#{user.username}"
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

    def respond(socket, data)
      user = graceful_find(User, data['user'], socket)
      return if user.nil?

      if data['event'] == 'feed'
        feed_event(user, socket)
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
      end
    end
  end
end
