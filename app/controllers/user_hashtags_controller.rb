class UserHashtagsController < ApplicationController
  before_action :require_login

  def update
    user_hashtag = UserHashtag.find(params[:id])

    if user_hashtag.favourite?
      user_hashtag.update(favourite: false)
    else
      if UserHashtag.where(user_id: current_user.id, favourite: true).count < APP_CONFIG['max_faves']
        user_hashtag.update(favourite: true)
      else
        redirect_to feed_index_path(tab: 'favourites'),
                    alert: "You already have #{APP_CONFIG['max_faves']} favourites, remove some to add a new one!"
        return
      end
    end

    redirect_to request.referer + params[:backurl]
  end

  def update_last_visit
    ch = current_user.user_hashtags.find_by hashtag_id: params[:id]
    ch.update_attribute(:last_visited, Time.now.utc)

    respond_to do |format|
      format.json { render json: {} }
      format.html { redirect_to feed_index_path }
    end
  end
end
