create_websocket = (events) ->
  uri = websocket_scheme + websocket_host
  ws = new WebSocket(uri)

  ws.onopen = ->
    events['open'] ws

  ws.onclose = ->
    events['close']

  ws.onmessage = (message) ->
    data = JSON.parse message.data
    console.log data

    event_handler = events[data.event]
    if event_handler != undefined
      event_handler(data)
    else
      console.log 'Unknown event "' + data.event + '"'

  return ws

on_notification = ->
  count = $('.notif-count')
  t = Number(count.text())
  if t == 0
    $('.notif-count').append("<span class='badge badge-success'>1</span>");
  else
    $('.notif-count .badge').text(t + 1)

set_star_hover = ->
  $('.like-icon').hover( ->
      $(this).text 'star_half'
      return
    , ->
      if $(this).hasClass( "like-icon-liked" )
        $(this).text 'star'
        return
      else
        $(this).text 'star_border'
    )

change_thumb = (t) ->
  if $(t).hasClass( "like-icon-liked" )
    $(t).removeClass( "like-icon-liked" )
    $(t).text 'star_border'
  else
    $(t).addClass( "like-icon-liked" )
    $(t).text 'star'

on_like = (data) ->
  count = $('#' + data.message + ' .like-badge')
  count.text(Number(count.text()) + 1)

on_dislike = (data) ->
  count = $('#' + data.message + ' .like-badge')
  count.text(Number(count.text()) - 1)

format_timestamp = (timestamp) ->
  if !moment.isMoment(timestamp)
    timestamp = moment.utc(timestamp)
  timestamp.local().format('MMM D, H:mm')

add_multiple_messages = (data, add_message, drawMarker = true) ->
  last_visit = null
  if (drawMarker)
    last_visit = moment.utc($('#last-visit')[0].value)

  markerDrawn = false
  for message in data.messages
    if (drawMarker and !markerDrawn and moment.utc(message.timestamp).isAfter(last_visit))
      $('.chatbox').append ''+
        '<div class="line text-center">' +
          '<span>Since<span class="timestamp">' + format_timestamp(last_visit) + '</span></span>'+
        '</div>'
      markerDrawn = true
    add_message message

add_click_handler_to_likes = (element, socket) ->
  user = $('#user-id')[0].value

  $(element).click (event) ->
    event.preventDefault()
    message = $(this)[0].id.substr(5)
    change_thumb $('#' + message + ' i')

    json = JSON.stringify
      event: 'like'
      user: user
      message: message
    socket.send json

exports = this
exports.add_multiple_messages = add_multiple_messages
exports.format_timestamp = format_timestamp
exports.create_websocket = create_websocket
exports.on_notification = on_notification
exports.on_like = on_like
exports.on_dislike = on_dislike
exports.change_thumb = change_thumb
exports.set_star_hover = set_star_hover
exports.add_click_handler_to_likes = add_click_handler_to_likes
