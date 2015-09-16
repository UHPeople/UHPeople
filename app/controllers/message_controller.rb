class MessageController < ApplicationController
  before_action :require_login

  def get_message_likers
    respond_to do |format|
      format.json do
        message = Message.find(params[:id])
        m = message.likes.map(&:user_id)
        likers = User.where(id: m)#.map(&:name)
        json = {
          'likers': likers = User.where(id: m).map(&:name)
        }
        render json: {
          :liker => likers.to_json(:only => [:name]) }
      end
      format.html { redirect_to feed_index_path }
    end
  end
end
