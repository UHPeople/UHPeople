class UsersController < ApplicationController
  before_action :require_non_production, only: [:new, :create]
  before_action :require_login, only: [:show, :edit, :update]
  before_action :set_user, only: [:show, :edit, :update]
  before_action :set_campuses, only: [:new, :show, :edit, :update]
  before_action :user_is_current, only: [:edit, :update]

  def index
    @users = User.all
    respond_to do |format|
      format.json do
        render json: 'Not logged in' if current_user.nil?

        users = @users.collect do |user|
          { id: user.id, name: user.name, avatar: user.avatar.url(:thumb) }
        end

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

  private

  def user_is_current
    redirect_to root_path unless params[:id].to_s === session[:user_id].to_s
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :name, :title, :email, :campus, :unit, :about, :avatar)
  end

  def edit_user_params
    params.require(:user).permit(:title, :email, :campus, :unit, :about, :avatar)
  end

  def set_campuses
    @campuses = ['',
                 'City Centre Campus',
                 'Kumpula Campus',
                 'Meilahti Campus',
                 'Viikki Campus']
  end
end
