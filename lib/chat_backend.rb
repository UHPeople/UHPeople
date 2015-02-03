require 'faye/websocket'
require 'thread'
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
      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })

        ws.on :open do |event|
          p [:open, ws.object_id]
          @clients << ws
        end

        ws.on :message do |event|
          data = JSON.parse(event.data)

          asd = Message.create content: data['content'], hashtag_id: 1, user_id: 1
          p [:message, asd.content, asd.save]

          @clients.each {|client| client.send(sanitize(event.data)) }
        end

        ws.on :close do |event|
          p [:close, ws.object_id, event.code, event.reason]
          @clients.delete(ws)
          ws = nil
        end

        ws.rack_response

      else
        @app.call(env)
      end
    end

    private

    def sanitize(message)
      json = JSON.parse(message)
      json.each {|key, value| json[key] = ERB::Util.html_escape(value) }
      JSON.generate(json)
    end
  end
end