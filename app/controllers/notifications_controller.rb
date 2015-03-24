class NotificationsController < ApplicationController

	before_action :require_login

  def index
  	@notifications = current_user.notifications.all
  end

  def update
  	notif = Notification.find_by_id(params[:id])
  	notif.visible = false
  	notif.save
  	redirect_to notifications_path
  end
end
