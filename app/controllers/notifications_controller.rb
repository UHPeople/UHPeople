class NotificationsController < ApplicationController

	before_action :require_login

  def index
  	@notifications = current_user.notifications.all
  end
end
