class SearchController < ApplicationController
  before_action :require_login
  before_action :set_search, only: [:index]

  def index
    @hashtag = Hashtag.new tag: @search

    @hashtags = Hashtag.where('tag ilike ?', "%#{@search}%")
    @users = User.where('name ilike ?', "%#{@search}%")

    @hashtags_exact = Hashtag.where('tag ilike ?', "#{@search}")
  end

  private

  def set_search
    @search = params[:search]
  end
end
