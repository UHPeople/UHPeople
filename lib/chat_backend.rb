require 'faye/websocket'
require 'thread'
require 'json'
require 'erb'

module UHPeople
  class ChatBackend
    class Client
      def new(socket, user)
        @socket = socket
        @user = user
      end

      def send(data)
        @socket.send(data)
      end
    end

    KEEPALIVE_TIME = 15

    def initialize(app)
      @app     = app
      @clients = []
    end

    def call(env)
      if Faye::WebSocket.websocket? env
        ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })

        ws.on :open do |event|
          p "open"

          @clients << ws #Client.new(ws, nil)
        end

        ws.on :message do |event|
          p "message"

          data = JSON.parse(event.data)
          response = generate_response data
          @clients.each { |client| client.send(response) }
        end

        ws.on :close do |event|
          p "close"

          @clients.delete(ws)
          ws = nil

          onlines = online_users
          @clients.each { |client| client.send(onlines) }
        end

        ws.rack_response
      else
        @app.call(env)
      end
    end

    private

    def sanitize(json)
      json.each {|key, value| json[key] = ERB::Util.html_escape(value) }
      JSON.generate(json)
    end

    def online_users
      onlines = @clients.map { |client| client.user.id }
      json = {'event': 'online', 'onlines': onlines}
      
      p json

      return JSON.generate(json)
    end

    def generate_response(data)
      if data['event'] == 'message'
        p "message event"

        user = User.find(data['user'])
        hashtag = Hashtag.find(data['hashtag'])

        if user.hashtags.include? hashtag
          message = Message.create content: data['content'],
                                   hashtag_id: data['hashtag'],
                                   user_id: data['user']

          data['user'] = user.name
          data['timestamp'] = message.timestamp

          if message.valid?
            return sanitize(data)
          end
        end
      elsif data['event'] == 'online'
        p "online event"

        return online_users
      end 
    end
  end
end