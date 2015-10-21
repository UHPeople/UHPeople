
kickass_notifyer = (message) ->
  notification = new Notification(message)

exports = this
exports.notify = kickass_notifyer

notifyMe = ->
  # Check if the browser supports notifications
  if !('Notification' of window)
    alert 'This browser does not support system notifications'
  else if Notification.permission == 'granted'
    notification = new Notification('UHPeople notifications on!')
  else if Notification.permission != 'denied'
    Notification.requestPermission (permission) ->
      # If the user accepts, let's create a notification
      if permission == 'granted'
        notification = new Notification('UHPeople notifications on!')
      return
  return

ready = ->
  if not $(location).attr('pathname') == "/notifications"
    console.log('not notif page')
    return
  else
    console.log('notif page')

  if Notification.permission != 'granted'
    $('#web_notifications_on').removeAttr('checked')

  $('#web_notifications_on').change () ->
    if $(this).is(':checked')
      notifyMe()
    else
      console.log 'not checked'

$(document).ready(ready)
$(document).on('page:load', ready)
