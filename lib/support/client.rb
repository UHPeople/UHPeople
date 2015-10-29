class Client
  attr_accessor :socket
  attr_accessor :user
  attr_accessor :hashtags

  def initialize(socket, user, hashtag = nil)
    @socket = socket
    @user = user
    @hashtags = (hashtag.class != Array) ? [hashtag] : hashtag
  end

  def send(data)
    @socket.send(data)
  end
end
