class UsersController < ApplicationController
  before_action :require_non_production, only: [:new, :create]
  before_action :require_login, only: [:show, :edit, :update]
  before_action :set_user, only: [:show, :edit, :update]

  def index
    @users = User.all

    respond_to do |format|
      format.json do
        render json: current_user.nil? ? 'Not logged in' : @users
      end

      format.html { require_non_production }
    end
  end

  def new
    @user = User.new
  end

  def update
    respond_to do |format|
      if @user.update(edit_user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  def create
    @user = User.create(user_params)
    session[:user_id] = @user.id

    respond_to do |format|
      format.html { redirect_to @user, notice: 'User was successfully created.' }
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :name, :title, :email, :campus, :unit, :about, :avatar)
  end

  def edit_user_params
    params.require(:user).permit(:title, :email, :campus, :unit, :about, :avatar)
  end
end
