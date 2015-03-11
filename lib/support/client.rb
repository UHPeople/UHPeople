class Client
  attr_accessor :socket
  attr_accessor :user
  attr_accessor :hashtags

  def initialize(socket, user, hashtags)
    @socket = socket
    @user = user
    @hashtags = hashtags
  end

  def send(data)
    @socket.send(data)
  end
end
