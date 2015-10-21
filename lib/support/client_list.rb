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

  def remove_client(socket)
    client = @clients.find { |client| client.socket == socket }
    hashtags = client.hashtags
    @clients.delete(client)

    broadcast(online_users, nil)

    User.find_by(id: client.user).update_attribute(:last_online, Time.now.utc)
    UserHashtag.find_by(hashtag_id: hashtags.first, user_id: user)
      .update_attribute(:last_visit, Time.now.utc) if hashtags.count == 1
  end

  def add_client(socket, user, hashtag)
    hashtags = (hashtag.class == Fixnum) ? [hashtag] : hashtag

    client = @clients.find { |client| client.user == user && client.hashtags == hashtags }
    unless client.nil?
      client.socket.close
      @clients.delete(client)
    end

    @clients << Client.new(socket, user, hashtag)

    broadcast(online_users, nil)
  end

  def online_users
    onlines = @clients.map { |client| client.user }
    json = { 'event': 'online', 'onlines': onlines }
    JSON.generate(json)
  end
end
