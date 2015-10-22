# tää on ihan turha mut halusinpa tehdä luokan
class Web_notification
  constructor: () ->
    @options =
      icon: "/assets/helsinki53x50.png"
      body: ''

  new_message_notification: (tricker, channel, message) ->
    @options.body = message
    notification = new Notification(tricker + ' at #' + channel, @options)
    setTimeout(notification.close.bind(notification), 2000);

  toggle_notification: () ->
    @options.body = 'Notifications turned on!'
    notification = new Notification('UHPeople', @options)
    setTimeout(notification.close.bind(notification), 2000);

exports = this
exports.Web_notification = Web_notification

set_notifications_on = ->
  # Check if the browser supports notifications
  if !('Notification' of window)
    alert 'This browser does not support system notifications'
  else if Notification.permission == 'granted'
    notification = new Web_notification().toggle_notification()
  else if Notification.permission != 'denied'
    Notification.requestPermission (permission) ->
      # If the user accepts, let's create a notification
      if permission == 'granted'
        notification = new Web_notification().toggle_notification()
      return
  return

set_notifications_off = ->
  #if Notification.permission == 'granted' # turn to default
    #TODO: Dont know how to turn this off!!!

toggle_switch = ->
  if !'Notification' of window or Notification.permission == 'denied'
    $('#web_notifications_switch').removeAttr('checked')
  else if Notification.permission == 'default'
    $('#web_notifications_switch').removeAttr('checked')
    $('#web_notifications_switch').removeAttr('disabled')
    $('#sys_notif_disabled_info').hide()
  else # permission 'granded'
    $('#sys_notif_disabled_info').hide()
    $('#web_notifications_switch').removeAttr('disabled')

ready = ->
  if not $(location).attr('pathname') == "/notifications"
    return
  else

  toggle_switch()

  $('#web_notifications_switch').change () ->
    if $(this).is(':checked')
      set_notifications_on()
    else
      set_notifications_off()

$(document).ready(ready)
$(document).on('page:load', ready)
