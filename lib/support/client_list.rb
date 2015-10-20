module ClientList
  def initialize(*)
    @clients = []
  end

  def broadcast(json, hashtag)
    @clients.each { |client| client.send(json) if client.hashtags.include? hashtag }
  end

  def send(json, user)
    @clients.each { |client| client.send(json) if client.user == user }
  end

  def remove_client(socket)
    client = @clients.find { |client| client.socket == socket }
    hashtags = client.hashtags
    @clients.delete(client)

    User.find_by(id: client.user).update_attribute(:last_online, Time.now.utc)

    return if hashtags.count > 1

    hashtag = hashtags.first
    broadcast(online_users(hashtag), hashtag)
    UserHashtag.find_by(hashtag_id: hashtag, user_id: user).update_attribute(:last_visit, Time.now.utc)
  end

  def add_client(socket, user, hashtag)
    hashtags = (hashtag.class == Fixnum) ? [hashtag] : hashtag

    client = @clients.find { |client| client.user == user && client.hashtags == hashtags }
    unless client.nil?
      client.socket.close
      @clients.delete(client)
    end

    @clients << Client.new(socket, user, hashtag)
  end

  def online_users(hashtag)
    onlines = @clients.map { |client| client.user if client.hashtags == [hashtag] }.compact
    json = { 'event': 'online', 'hashtag': hashtag, 'onlines': onlines }
    JSON.generate(json)
  end
end
