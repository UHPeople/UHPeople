module ClientList
  def initialize(*)
    @clients = []
  end

  def broadcast(json, hashtag = nil)
    if hashtag.nil?
      @clients.each { |client| client.send(json) }
    else
      @clients.each { |client| client.send(json) if client.hashtags.include? hashtag }
    end
  end

  def send(json, user)
    @clients.each { |client| client.send(json) if client.user == user }
  end

  def subscribed?(user, hashtag)
    @clients.each do |client|
      return true if client.user == user && client.hashtags.include?(hashtag)
    end

    false
  end

  def online?(user)
    @clients.each do |client|
      return true if client.user == user
    end

    false
  end

  def remove_client(socket)
    client = @clients.find { |client| client.socket == socket }
    @clients.delete(client)

    broadcast(online_users) if count(client.user) == 0

    client.user.update_attribute(:last_online, Time.now.utc)

    user_hashtag = client.user.user_hashtags.find_by(hashtag_id: client.hashtags.first) if client.hashtags.count == 1
    user_hashtag.update_attribute(:last_visited, Time.now.utc) if user_hashtag.present?
  end

  def add_client(socket, user)
    @clients << Client.new(socket, user)

    if count(user) == 1
      broadcast(online_users)
    else
      send(online_users, user)
    end
  end

  def subscribe(socket, hashtag)
    client = find(socket)
    hashtags = (hashtag.class != Array) ? [hashtag] : hashtag
    client.hashtags = (client.hashtags + hashtags).compact
  end

  def online_users
    onlines = @clients.map { |client| client.user.id }
    json = { 'event': 'online', 'onlines': onlines }
    JSON.generate(json)
  end

  def authenticated(socket)
    find(socket).present?
  end

  def find(socket)
    @clients.find { |client| client.socket == socket }
  end

  def count(user)
    @clients.count { |client| client.user == user }
  end
end
