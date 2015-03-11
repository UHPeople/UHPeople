module ClientList
  def initialize(*)
    @clients = []
  end

  def broadcast(json, hashtag)
    @clients.each { |client| client.send(json) if client.hashtag.include? hashtag }
  end

  def remove_client(socket)
    client = @clients.find { |client| client.socket == socket }
    hashtags = client.hashtags

    @clients.delete(client)

    broadcast(online_users(hashtags.first), hashtags.first) if hashtags.count == 1
  end

  def add_client(socket, user, hashtags)
    hashtags = [hashtags] if hashtags.class == Fixnum
    
    client = @clients.find { |client| client.user == user and client.hashtags == hashtags }
    unless client.nil?
      client.socket.close()
      @clients.delete(client)
    end

    @clients << Client.new(socket, user, hashtags)
  end

  def online_users(hashtag)
    onlines = @clients.map { |client| client.user if client.hashtags == [hashtag] }.compact
    json = { 'event': 'online', 'hashtag': hashtag, 'onlines': onlines }
    JSON.generate(json)
  end
end
