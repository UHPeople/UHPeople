ws = null

create_websocket = (events) ->
  uri = websocket_scheme + websocket_host
  ws = new WebSocket(uri)

  ws.onopen = ->
    console.log 'opened'

    ws.send JSON.stringify
      event: 'online'
      user: $('input#user-id').val()
      token: $('input#user-token').val()

    if events['open'] != undefined
      events['open'] ws

  ws.onclose = ->
    console.log 'closed'
    if events['close'] != undefined
      events['close']

  ws.onmessage = (message) ->
    data = JSON.parse message.data
    console.log data

    event_handler = events[data.event]
    if event_handler != undefined
      event_handler(data)
    else
      console.log 'Unhandled event "' + data.event + '"'
  return ws

on_notification = ->
  count = $('.notif-count .badge')
  if not count.length
    $('.notif-count').append("<span class='badge badge-success'>1</span>");
  else
    t = Number(count.text())
    count.text(t + 1)

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

change_like_star = (t) ->
  if $(t).hasClass 'like-icon-liked'
    $(t).removeClass 'like-icon-liked'
    $(t).text 'star_border'
    return 'dislike'
  else
    $(t).addClass 'like-icon-liked'
    $(t).text 'star'
    return 'like'

on_like = (data, prefix = '') ->
  count = $('#' + prefix + data.message + ' .like-badge')
  if not count.length
    on_notification
  else
    count.text(Number(count.text()) + 1)

on_dislike = (data, prefix = '') ->
  count = $('#' + prefix + data.message + ' .like-badge')
  if not count.length
    on_notification
  else
    count.text(Number(count.text()) - 1)

format_timestamp = (timestamp) ->
  if !moment.isMoment(timestamp)
    timestamp = moment.utc(timestamp)
  timestamp.local().fromNow() #.format('MMM D, H:mm')

add_multiple_messages = (data, add_message, drawMarker = true) ->
  for message in data.messages
    add_message message

  if drawMarker and $('div.line').length == 0
    last_visit = moment.utc($('#last-visit')[0].value)

    $('<div class="line text-center">' +
        '<span>Since<span class="timestamp" data-timestamp="' + last_visit + '">' +
          format_timestamp(last_visit) +
        '</span></span>'+
      '</div>').insertBefore('.new_messages:first')

add_click_handler_to_likes = (element, socket) ->
  user = $('#user-id')[0].value

  $(element).off 'click'
  $(element).on 'click', (event) ->
    event.preventDefault()

    id = $(this)[0].id.split('-')
    message = id[id.length - 1]

    event = change_like_star $('.like-this[id$='+message+'] i')

    socket.send JSON.stringify
      event: event
      user: user
      message: message

add_mouseover_to_get_likers = (prefix, id) ->
  $('#' + prefix + id).hover( ->
    if (Number $(this).text() > 0)
      append_tooltip_element(this, id, prefix)
      get_likers_json_to_tooltip(id, prefix)
    else
      $('[for="'+ prefix + id + '"]').remove()
    return
  , ->
    $('[for="'+ prefix + id + '"]').empty()
    return
  )

append_tooltip_element = (element, id, prefix) ->
  div = document.createElement('div')
  div.setAttribute('class', 'mdl-tooltip')
  div.setAttribute('for', '' + prefix + id)
  componentHandler.upgradeElement(div)
  $(element).parent().append( div )

get_likers_json_to_tooltip = (id, prefix) ->
  jsonData = $.getJSON("../get_message_likers/" + id)
  jsonData.done (json)->
    $('[for="'+ prefix + id + '"]').append(json.likers.join(', '))

exports = this
exports.add_multiple_messages = add_multiple_messages
exports.format_timestamp = format_timestamp
exports.create_websocket = create_websocket
exports.on_notification = on_notification
exports.add_mouseover_to_get_likers = add_mouseover_to_get_likers
exports.on_like = on_like
exports.on_dislike = on_dislike
exports.change_like_star = change_like_star
exports.set_star_hover = set_star_hover
exports.add_click_handler_to_likes = add_click_handler_to_likes
