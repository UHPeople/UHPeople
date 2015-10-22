set_online = (id) ->
  element = $('h2#'+id)
  if element.length
    element.addClass('online')
    $('.last-online').hide()

on_online = (data) ->
  set_online id for id in data.onlines

ready = ->
  if $('#hashtag-id').length or $('#feed').length
    return
  else
    console.log('non chat page detected!')

  ws = create_websocket {
    'online': on_online,
    'notification': on_notification
  }

$(document).ready(ready)
$(document).on('page:load', ready)
