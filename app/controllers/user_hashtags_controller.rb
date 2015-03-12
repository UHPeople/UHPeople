class UserHashtagsController < ApplicationController
  before_action :require_login

  def update
    @user_hashtag = UserHashtag.find(params[:id])
    @max_faves = 5

    if @user_hashtag.favourite?
      @user_hashtag.update(favourite: false)
    else
      if (UserHashtag.where(user_id: current_user.id, favourite: true)).count < @max_faves
        @user_hashtag.update(favourite: true)
      else
        redirect_to feed_index_path(tab: 'favourites'), notice: "You already have #{@max_faves} favourites, remove some to add a new one!" and return
      end
    end

    redirect_to request.referer + params[:backurl]
  end
end
