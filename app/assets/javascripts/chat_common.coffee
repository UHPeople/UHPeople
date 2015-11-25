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
  badge = $('.notif-link .mdl-badge')
  badge.attr('data-badge', Number(badge.attr('data-badge')) + 1)

set_star_hover = ->
  $('.like-icon').hover ->
      $(this).text 'star_half'
    , ->
      if $(this).hasClass 'like-icon-liked'
        $(this).text 'star'
      else
        $(this).text 'star_border'

change_like_star = (t) ->
  if $(t).hasClass 'like-icon-liked'
    $(t).removeClass 'like-icon-liked'
    $(t).text 'star_border'
    return 'dislike'
  else
    $(t).addClass 'like-icon-liked'
    $(t).text 'star'
    return 'like'

on_like = (data, prefix = 'tt') ->
  count = $('#' + prefix + data.message + ' .like-badge')
  if not count.length
    on_notification
  else
    count.text(Number(count.text()) + 1)
    tooltip = count.siblings('.mdl-tooltip')
    if tooltip.length
      tooltip.text(tooltip.text() + ', ' + data.user)
    else
      count.parent().append '' +
        '<div class="mdl-tooltip" for="' + prefix + data.message + '">' + data.user + '</div>'
      componentHandler.upgradeElement($('[for="'+ prefix + data.message + '"]')[0])

on_dislike = (data, prefix = '') ->
  count = $('#' + prefix + data.message + ' .like-badge')
  if count.length
    count.text(Number(count.text()) - 1)
    tooltip = count.siblings('.mdl-tooltip')
    if tooltip.length
      text = tooltip.text()
      text = text.replace(', '+data.user, '') # remove from the middle
      text = text.replace(data.user+', ', '') # remove from the start
      text = text.replace(data.user, '') # remove if only one
      if text.length
        tooltip.text(text)
      else
        tooltip.remove()

format_timestamp = (timestamp) ->
  if !moment.isMoment(timestamp)
    timestamp = moment.utc(timestamp)
  timestamp.local().fromNow()

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
      message: message

add_mouseover_to_show_likers = (selector, likers) ->
  badge = $('#' + selector)
  if (Number(badge.text()) > 0)
    badge.parent().append '' +
      '<div class="mdl-tooltip" for="' + selector + '">' +
        likers.join(', ') +
      '</div>'
    componentHandler.upgradeElement($('[for="'+ selector + '"]')[0])

construct_photo_message = (photos) ->
  div = ''
  if photos.length
    div = '<div style="display: inline-block;">'
    for photo in photos
      div += """
          <a href="#" class="image__show" id="#{photo.id}">
            <img style="padding: 8px;" src="#{photo.url}"/>
          </a>
        """
    div += '</div>'
  return div

exports = this
exports.add_multiple_messages = add_multiple_messages
exports.format_timestamp = format_timestamp
exports.create_websocket = create_websocket
exports.on_notification = on_notification
exports.add_mouseover_to_show_likers = add_mouseover_to_show_likers
exports.on_like = on_like
exports.on_dislike = on_dislike
exports.change_like_star = change_like_star
exports.set_star_hover = set_star_hover
exports.add_click_handler_to_likes = add_click_handler_to_likes
exports.construct_photo_message = construct_photo_message
