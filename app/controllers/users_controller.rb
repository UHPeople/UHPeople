class UsersController < ApplicationController
  before_action :require_non_production, only: [:new, :create]
  before_action :require_login, only: [:show, :edit, :update]
  before_action :set_user, only: [:show, :edit, :update]
  before_action :set_campuses, only: [:new, :show, :edit, :update]
  before_action :user_is_current, only: [:edit, :update]
  before_action :show_profile_photo, only: [:show, :edit]

  def index
    @users = User.all
    respond_to do |format|
      format.json do
        render json: 'Not logged in' if current_user.nil?

        users = @users.collect { |user|
          { id: user.id, name: user.name }
        }

        render json: users
      end

      format.html { require_non_production }
    end
  end

  def new
    @user = User.new
  end

  def update
    if @user.update(@user.first_time ? user_params : edit_user_params)
      if @user.first_time
        redirect_to feed_index_path
      else
        redirect_to @user, notice: 'User was successfully updated.'
      end
    else
      render action: 'edit'
    end
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to @user, notice: 'User was successfully created.'
    else
      redirect_to action: 'new'
    end
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
    u = current_user
    u.profilePicture = params[:pic_id].to_i
    u.save
    redirect_to user_path(id: u.id)
  end

  private

  def user_is_current
    redirect_to root_path unless params[:id].to_s === session[:user_id].to_s
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :name, :title, :email, :campus, :unit, :about, :profilePicture)
  end

  def edit_user_params
    params.require(:user).permit(:title, :email, :campus, :unit, :about, :profilePicture)
  end

  def set_campuses
    @campuses = ['City Centre Campus',
                 'Kumpula Campus',
                 'Meilahti Campus',
                 'Viikki Campus']
  end

  def show_profile_photo
      photo = Photo.find_by id: @user.profilePicture
      if photo != nil
        @user_photo = photo.image.url(:medium)
        @photo_text = photo.image_text
      else
        @user_photo = ""
        @photo_text = ""
      end
  end
end
