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

  def edit

  end

  def update
    respond_to do |format|
      if @user.first_time
        if @user.update(user_params)
          format.html { redirect_to feed_index_path }
        else
          format.html { render action: 'edit' }
        end
      else
        if @user.update(edit_user_params)
          format.html { redirect_to @user, notice: 'User was successfully updated.' }
        else
          format.html { render action: 'edit' }
        end
      end
    end
  end

  def create
    @user = User.create(user_params)
    if @user.save
      session[:user_id] = @user.id

      respond_to do |format|
        format.html { redirect_to @user, notice: 'User was successfully created.' }
      end
    else
      respond_to do |format|
        format.html { redirect_to feed_index_path, notice: "Oops, something went wrong. User couldn't be created." }
      end
    end
  end

  def set_first_time_use
    current_user.update_attribute(:first_time, false)
    redirect_to notifications_path
  end

  def set_profile_picture
    u = current_user
    u.profilePhoto = params[:pic_id].to_i
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
    params.require(:user).permit(:username, :name, :title, :email, :campus, :unit, :about, :profilePhoto)
  end

  def edit_user_params
    params.require(:user).permit(:title, :email, :campus, :unit, :about, :profilePhoto)
  end

  def set_campuses
    @campuses = ["",
                 "City Centre Campus",
                 "Kumpula Campus",
                 "Meilahti Campus",
                 "Viikki Campus"]
  end

  def show_profile_photo
      photo = Photo.find_by id: @user.profilePhoto
      if photo != nil
        @user_photo = photo.image.url(:medium)
      else
        @user_photo = ""
      end
  end
end
