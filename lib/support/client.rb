class Client
  attr_accessor :socket
  attr_accessor :user
  attr_accessor :hashtags

  def initialize(socket, user, hashtag)
    @socket = socket
    @user = user
    @hashtags = (hashtag.class == Fixnum) ? [hashtag] : hashtag
  end

  def send(data)
    @socket.send(data)
  end
end
