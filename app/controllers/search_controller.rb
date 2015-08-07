class SearchController < ApplicationController
  before_action :require_login
  before_action :set_search, only: [:index]

  def index
    hashtags_only = false
    if @search =~ /^#[^#]*$/
      @search = @search[1..-1]
      hashtags_only = true
    end

    @hashtag = Hashtag.new tag: @search

    @hashtags = Hashtag.where('tag ilike ?', "%#{@search}%")
    @users = User.where('name ilike ?', "%#{@search}%") unless hashtags_only

    @hashtags_exact = Hashtag.where('tag ilike ?', "#{@search}")

    redirect_to @users.first if @hashtags.empty? and @users.count == 1
    redirect_to hashtag_path(@hashtags.first.tag) if @users.empty? and @hashtags.count == 1
  end

  private

  def set_search
    @search = params[:search]
  end
end
