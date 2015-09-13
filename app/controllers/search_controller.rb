class SearchController < ApplicationController
  before_action :require_login
  before_action :set_search, only: [:index]

  def index
    # Strips leading '#' from search
    hashtags_only = false
    if @search =~ /^#[^#]*$/
      @search = @search[1..-1]
      hashtags_only = true
    end

    @hashtag = Hashtag.new tag: @search

    @hashtags = Hashtag.where('tag ilike ?', "%#{@search}%").order('tag ASC')
    @hashtags_exact = Hashtag.where('tag ilike ?', "#{@search}")
    @hashtags_topic_match = (Hashtag.where('topic ilike ?', "%#{@search}%").order('tag ASC') - @hashtags)

    @users = User.where('name ilike ?', "%#{@search}%").order('name ASC') unless hashtags_only
    @users_exact = User.where('name ilike ?', "#{@search}").order('name ASC') unless hashtags_only

    redirect_to @users_exact.first if !hashtags_only &&
                                      (@hashtags.nil? || @hashtags.empty?) &&
                                      @users_exact.count == 1 && @users.count == 1

    redirect_to hashtag_path(@hashtags_exact.first.tag) if (@users.nil? || @users.empty?) &&
                                                           @hashtags_exact.count == 1 && @hashtags.count == 1
  end

  private

  def set_search
    @search = params[:search]
  end
end
