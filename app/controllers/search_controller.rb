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

    @hashtags = Hashtag.where('tag ilike ?', "%#{@search}%").order('tag ASC')
    @users = User.where('name ilike ?', "%#{@search}%").order('name ASC') unless hashtags_only

    @hashtags_exact = Hashtag.where('tag ilike ?', "#{@search}")
    @hashtags_topic_match = Hashtag.where('topic ilike ?', "%#{@search}%").order('tag ASC')
    @hashtags_topic_match = (@hashtags_topic_match - @hashtags)

  end

  private

  def set_search
    @search = params[:search]
  end
end
