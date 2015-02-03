class MessagesController < ApplicationController
  def new
    @message = Message.new
  end

  def create
    @message = Message.create params.require(:message).permit(:content, :user_id, :hashtag_id)
    
    @message.user_id = 1
    @message.hashtag_id = 1
    
    if @message.save
    end
  end

  def destroy
  end
end

