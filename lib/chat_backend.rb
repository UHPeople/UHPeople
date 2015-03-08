require 'faye/websocket'
require 'json'
require 'erb'

module UHPeople
  class ChatBackend
    KEEPALIVE_TIME = 15

    def initialize(app)
      @app     = app
      @clients = []
    end

    def call(env)
      if Faye::WebSocket.websocket? env
        ws = Faye::WebSocket.new(env, nil, ping: KEEPALIVE_TIME)

        ws.on :message do |event|
          data = JSON.parse(event.data)
          respond ws, data
        end

        ws.on :close do |event|
          remove_online_user ws
          ws = nil

          broadcast online_users
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
      broadcast JSON.generate(json)
    end

    def find_client_by_socket(socket)
      @clients.find { |s, u| socket == s }
    end

    def find_client_by_user(user)
      @clients.find { |s, u| user == u }
    end

    def remove_online_user(socket)
      client = find_client_by_socket socket
      @clients.delete(client)
    end

    def sanitize(json)
      json.each { |key, value| json[key] = ERB::Util.html_escape(value) }
      JSON.generate(json)
    end

    def online_users
      onlines = @clients.map { |socket, user| user }
      json = { 'event': 'online', 'onlines': onlines }
      JSON.generate(json)
    end

    def send_error(socket, error)
      json = { 'event': 'error', 'content': error }
      socket.send(JSON.generate(json))
    end

    def broadcast(json)
      @clients.each { |socket, user| socket.send(json) }
    end

    def add_client(socket, user)
      client = find_client_by_user user
      @clients.delete(client) unless client.nil?

      @clients << [socket, user]
    end

    def respond(socket, data)
      begin
        user = User.find(data['user'])
      rescue ActiveRecord::RecordNotFound
        send_error socket, 'Invalid user id'
        return
      end

      begin
        hashtag = Hashtag.find(data['hashtag'])
      rescue ActiveRecord::RecordNotFound
        send_error socket, 'Invalid hashtag id'
        return
      end

      unless user.hashtags.include? hashtag
        send_error socket, 'User not member of hashtag'
        return
      end

      if data['event'] == 'message'
        message = Message.create content: data['content'],
                                 hashtag_id: data['hashtag'],
                                 user_id: data['user']

        if message.valid?
          data['username'] = user.name
          data['timestamp'] = message.timestamp

          broadcast sanitize(data)
        else
          send_error socket, 'Invalid message'
          return
        end
      elsif data['event'] == 'online'
        add_client socket, data['user']
        broadcast online_users
      end
    end
  end
end
