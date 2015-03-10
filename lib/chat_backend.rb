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

        @app.call(env)
      end
    end

    # private

    def hashtag_callback(event, user, hashtag)
      json = { 'event': event, 'hashtag': hashtag.id, 'username': user.name, 'user': user.id }
      broadcast(JSON.generate(json), hashtag.id)
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

    def handle_errors(socket, data)
      user = graceful_find(User, data['user'], socket)
      return if user.nil?

      hashtag = graceful_find(Hashtag, data['hashtag'], socket)
      return if hashtag.nil?

      unless user.hashtags.include? hashtag
        send_error socket, 'User not member of hashtag'
        return
      end

      [user, hashtag]
    end

    def serialize(message)
      json = { 'event': 'message', 'content': ERB::Util.html_escape(message.content),
               'hashtag': message.hashtag_id, 'user': message.user_id, 'username': message.user.name,
               'timestamp': message.timestamp }
      JSON.generate json
    end

    def respond(socket, data)
      user, hashtag = handle_errors(socket, data)
      return if user.nil?

      if data['event'] == 'message'
        message = Message.create content: data['content'],
                                 hashtag_id: data['hashtag'],
                                 user_id: data['user']

        unless message.valid?
          send_error socket, 'Invalid message'
          return
        end

        broadcast(serialize(message), hashtag.id)
      elsif data['event'] == 'online'
        add_client socket, user.id, hashtag.id
        broadcast(online_users(hashtag.id), hashtag.id)
      end
    end
  end
end
