class LikeController < ApplicationController
  before_action :require_login

  def index
    like = Like.find_by(user_id: current_user.id, message_id: params[:id])
    if like == nil
      like = Like.new(user_id: current_user.id, message_id: params[:id])
      unless like.save
        redirect_to feed_index_path, alert: 'Something went wrong!'
        return
      end
    end

    respond_to do |format|
      format.json { render json: {} }
      format.html { redirect_to feed_index_path }
    end
  end

end
