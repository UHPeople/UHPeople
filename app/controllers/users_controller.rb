class UsersController < ApplicationController
  before_action :require_non_production, only: [:new]
  before_action :require_login, only: [:show, :edit, :update, :set_tab]
  before_action :set_user, only: [:show, :edit, :update]
  before_action :set_arrays, only: [:new, :show, :edit, :update, :shibboleth_callback]
  before_action :user_is_current, only: [:edit, :update]

  def index
    @users = User.all
    respond_to do |format|
      format.json do
        render(json: 'Not logged in') && return if current_user.nil?

        users = @users.collect do |user|
          {
            id: user.id,
            name: user.name,
            about: user.about.nil? ? nil : user.about.truncate(20, separator: ' '),
            avatar: user.profile_picture_url
          }
        end

        render json: users
      end

      format.html { require_non_production }
    end
  end

  def new
    request.env['omniauth.auth'] = {
      'info' => {
        'name' => '',
        'mail' => ''
      },

      'uid' => random_string
    }

    shibboleth_callback
  end

  def show
    @same_tags = @user.hashtags & current_user.hashtags
  end

  def update
    if @user.update(edit_user_params)
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def create
    @user = User.new(user_params)
    redirect_to(action: 'new') && return unless @user.save

    if params[:image]
      photo = Photo.new(user_id: @user.id, image: params[:image], image_text: params[:image_text])
      @user.update_attribute(:profilePicture, photo.id) if photo.save
    end

    session[:user_id] = @user.id

    redirect_to threehash_path
  end

  def set_first_time_use
    value = params[:value]
    current_user.update_attribute(:first_time, value)

    if value
      redirect_to feed_index_path
    else
      redirect_to notifications_path
    end
  end

  def set_profile_picture
    id = params[:pic_id].to_i

    begin
      Photo.find id
    rescue
      redirect_to current_user, alert: 'Invalid photo!'
      return
    end

    current_user.update_attribute(:profilePicture, id)
    redirect_to current_user, notice: 'Profile picture changed.'
  end

  def shibboleth_callback
    uid = request.env['omniauth.auth']['uid']
    @user = User.find_by username: uid

    if @user.nil?
      name = request.env['omniauth.auth']['info']['name'].force_encoding('utf-8')
      mail = request.env['omniauth.auth']['info']['mail']

      @user = User.new username: uid, name: name, email: mail
      render action: 'new'
    else
      session[:user_id] = @user.id
      redirect_to threehash_path
    end
  end

  def set_tab
    value = params[:value]
    current_user.update_attribute(:tab, tab_to_int(value))

    respond_to do |format|
      format.json { render json: {} }
      format.html { redirect_to feed_index_path }
    end
  end

  private

  def add_hashtag(tag)
    hashtag = Hashtag.find_by tag: tag
    hashtag = Hashtag.create tag: tag if hashtag.nil?

    @user.hashtags << hashtag
  end

  def tab_to_int(tab)
    (tab == 'feed') ? 1 : 0
  end

  def random_string
    # from http://codereview.stackexchange.com/questions/15958/
    range = ((48..57).to_a + (65..90).to_a + (97..122).to_a)
    ([nil] * 8).map { range.sample.chr }.join
  end

  def user_is_current
    redirect_to root_path unless params[:id].to_s === session[:user_id].to_s
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :name, :email, :campus, :about, :image, :image_title)
  end

  def edit_user_params
    params.require(:user).permit(:title, :campus, :unit, :about, :profilePicture)
  end

  def set_arrays
    @campuses = ['City Centre Campus', 'Kumpula Campus', 'Meilahti Campus', 'Viikki Campus']
  end
end
