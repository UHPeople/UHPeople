class NotificationsController < ApplicationController
  before_action :require_login
  before_action :set_notification, only: [:hide, :read]

  def index
    @notifications = current_user.notifications.all.order('created_at desc').first(20)
  end

  def hide
    @notif.update_attribute(:visible, false)
    redirect_to notifications_path
  end

  def read
    @notif.update_attribute(:visible, false)
    redirect_to hashtag_path(@notif.tricker_hashtag.tag)
  end

  private

  def set_notification
    @notif = Notification.find_by_id(params[:id])
  end
end
