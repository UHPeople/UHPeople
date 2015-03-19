class SearchController < ApplicationController
  before_action :require_login
  before_action :set_search, only: [:index]

  def index
    @hashtag = Hashtag.new

    @hashtags = Hashtag.where('tag ilike ?', "%#{@search}%")
    @users = User.where('name ilike ?', "%#{@search}%")

    @hashtags_exact = Hashtag.where('tag ilike ?', "#{@search}")

    respond_to do |format|
      format.json { render json: to_json(@hashtags, @users) }
      format.html { render :index }
    end
  end

  private

  def set_search
    @search = params[:search]
  end

  def to_json(hashtags, users)
    json = { 'hashtags': hashtags, 'users': users }
    return JSON.generate(json)
  end


end
