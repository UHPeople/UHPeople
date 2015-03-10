module ClientList
  def initialize(*)
    @clients = []
  end

  def broadcast(json, hashtag)
    @clients.each { |client| client.send(json) if client.hashtag == hashtag }
  end

  def remove_client(socket)
    client = @clients.find { |client| client.socket == socket }
    hashtag = client.hashtag

    @clients.delete(client)

    broadcast(online_users(hashtag), hashtag)
  end

  def add_client(socket, user, hashtag)
    client = @clients.find { |client| client.user == user and client.hashtag == hashtag }
    unless client.nil?
      client.socket.close()
      @clients.delete(client)
    end

    @clients << Client.new(socket, user, hashtag)
  end

  def online_users(hashtag)
    onlines = @clients.map { |client| client.user if client.hashtag == hashtag }.compact
    json = { 'event': 'online', 'hashtag': hashtag, 'onlines': onlines }
    JSON.generate(json)
  end
end
