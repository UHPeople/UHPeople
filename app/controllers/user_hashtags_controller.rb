class UserHashtagsController < ApplicationController
  before_action :require_login

  def update
    @user_hashtag = UserHashtag.find(params[:id])

    if @user_hashtag.favourite?
      @user_hashtag.update(favourite: false)
    else
      @user_hashtag.update(favourite: true)
    end

    redirect_to request.referer + params[:backurl]
  end
end
