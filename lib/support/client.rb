class Client
  attr_accessor :socket
  attr_accessor :user

  def initialize(socket, user)
    @socket = socket
    @user = user
  end

  def send(data)
    @socket.send(data)
  end
end
