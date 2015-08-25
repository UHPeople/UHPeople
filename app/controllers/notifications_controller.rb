class NotificationsController < ApplicationController
  before_action :require_login

  def index
    @notifications = current_user.notifications.all.order('created_at desc').first(20)
  end

  def seen
    current_user.notifications.each { |notif| notif.update_attribute(:visible, false) }
    redirect_to notifications_path
  end
end
