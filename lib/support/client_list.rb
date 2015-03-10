module ClientList
  def initialize(*)
    @clients = []
  end

  def broadcast(json)
    @clients.each { |client| client.send(json) }
  end

  def remove_client(socket)
    client = @clients.find { |client| client.socket == socket }
    @clients.delete(client)
  end

  def add_client(socket, user)
    client = @clients.find { |client| client.user == user }
    @clients.delete(client) unless client.nil?

    @clients << Client.new(socket, user)
  end

  def online_users
    onlines = @clients.map(&:user)
    json = { 'event': 'online', 'onlines': onlines }
    JSON.generate(json)
  end
end
