class SearchController < ApplicationController
  before_action :require_login
  before_action :set_search, only: [:index]

  def index
    hashtags_only = strip_hashtag

    @hashtags = Hashtag.where('tag ilike ?', "%#{@search}%").order('tag ASC')
                .includes(:messages).limit(10)

    @hashtags_exact = Hashtag.where('tag ilike ?', "#{@search}").limit(1)

    @hashtags_topic_match = (Hashtag.where('topic ilike ?', "%#{@search}%")
      .order('tag ASC').includes(:messages).limit(10) - @hashtags)

    @hashtag = Hashtag.new tag: @search if @hashtags.nil? || @hashtags.empty?

    @users = User.where('name ilike ?', "%#{@search}%").order('name ASC')
             .includes(:hashtags, :user_hashtags).limit(20) unless hashtags_only

    @users_exact = User.where('name ilike ?', "#{@search}").order('name ASC')
                   .limit(1) unless hashtags_only

    redirect_to @users_exact.first if !hashtags_only &&
                                      (@hashtags.nil? || @hashtags.empty?) &&
                                      @users_exact.count == 1 && @users.count == 1

    redirect_to hashtag_path(@hashtags_exact.first.tag) if (@users.nil? || @users.empty?) &&
                                                           @hashtags_exact.count == 1 && @hashtags.count == 1
  end

  private

  def strip_hashtag
    if @search =~ /^#[^#]*$/
      @search = @search[1..-1]
      return true
    end
    false
  end

  def set_search
    @search = params[:search]
  end
end
