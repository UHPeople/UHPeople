class Client
  attr_accessor :socket
  attr_accessor :user
  attr_accessor :hashtag

  def initialize(socket, user, hashtag)
    @socket = socket
    @user = user
    @hashtag = hashtag
  end

  def send(data)
    @socket.send(data)
  end
end
