class MessagesController < ApplicationController
  def new
    @message = Message.new
  end

  def create
    @message = Message.create params.require(:message).permit(:content, :user_id, :hashtag_id)
    if @message.save
    end
  end

  def destroy
  end
end

