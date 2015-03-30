class UsersController < ApplicationController
  before_action :require_non_production, only: [:new, :create]
  before_action :require_login, only: [:show, :edit, :update]
  before_action :set_user, only: [:show, :edit, :update]
  before_action :set_units, only: [:show, :edit, :update]
  before_action :user_is_current, only: [:edit, :update]

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

  def edit

  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        if @user.first_time
          format.html { redirect_to feed_index_path }
        else   
          format.html { redirect_to @user, notice: 'User was successfully updated.' }
        end
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

  def set_first_time_use
    current_user.update_attribute(:first_time, false)
    redirect_to notifications_path
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

  def set_units
    @campuses = ["City Centre Campus",
        "Kumpula Campus",
        "Meilahti Campus",
        "Viikki Campus", ""]

    @faculties = ["Faculty of Agriculture andForestry",
        "Faculty of Arts",
        "Faculty of Behavioural Sciences",
        "Faculty of Biological and Environmental Sciences",
        "Faculty of Law",
        "Faculty of Medicine",
        "Faculty of Pharmacy",
        "Faculty of Science",
        "Faculty of Social Sciences",
        "Faculty of Theology",
        "Faculty of Veterinary Medicine"]
  end

end
