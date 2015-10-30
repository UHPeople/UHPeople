class MessageController < ApplicationController
  before_action :require_login

  def get_message_likers
    respond_to do |format|
      format.json do
        message = Message.find(params[:id])
        likers = message.likers.map { |h| h.user.name }.as_json
        render json: { "likers": likers }
      end
      format.html { redirect_to feed_index_path }
    end
  end
end
