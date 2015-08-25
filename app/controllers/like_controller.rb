class LikeController < ApplicationController
  before_action :require_login

  def index

    like = Like.find_by like: params[:like]
    if like == nil
      like = Like.new like: params[:like]
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
