class LikeController < ApplicationController
  before_action :require_login

  def index
    message = Message.find_by id: params[:id]
    like = Like.find_by(user_id: current_user.id, message: message)
    if like.nil?
      like = Like.new(user_id: current_user.id, message: message)
      unless like.save
        redirect_to feed_index_path, alert: 'Something went wrong!'
        return
      end

      request.env['chat.like_callback'].call(message)
    end

    respond_to do |format|
      format.json { render json: {} }
      format.html { redirect_to feed_index_path }
    end
  end
end
