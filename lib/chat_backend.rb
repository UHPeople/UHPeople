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
          @clients << ws
        end

        ws.on :message do |event|
          data = JSON.parse(event.data)

          if data['event'] == 'message'
            user = User.find(data['user'])
            hashtag = Hashtag.find(data['hashtag'])

            if user.hashtags.include? hashtag
              message = Message.create content: data['content'],
                                       hashtag_id: data['hashtag'],
                                       user_id: data['user']

              data['user'] = user.name

              if message.valid?
                @clients.each { |client| client.send(sanitize(data)) }
              end
            end
          elsif data['event'] == 'online'
            # @clients.each { |client| client.send() }
          end 
        end

        ws.on :close do |event|
          @clients.delete(ws)
          ws = nil
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
  end
end