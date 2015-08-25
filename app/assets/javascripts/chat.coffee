set_online = (id) ->
  $('.nav-list li#' + id).addClass('online')

set_all_offline = (id) ->
  $('.nav-list li').removeClass('online')

scroll_to_bottom = ->
  $('.chatbox').stop().animate {
    scrollTop: $('.chatbox')[0].scrollHeight
  }, 800

compare_text = (a, b) ->
  $(a).text().toUpperCase().localeCompare($(b).text().toUpperCase())

compare_status = (a, b) ->
  if (a.className == "online")
    if (b.className == "online")
      return 0
    else
      return -1
  else if (b.className == "online")
    return 1

sort_members = ->
  list = $('ul.nav-list')

  items = list.children('li').get()
  items.sort (a, b) ->
    if a.className != b.className
      compare_status(a, b)
    else
      compare_text(a, b)

  $.each(items, (idx, itm) -> list.append(itm))

add_message = (data) ->
  size = $('.chatbox .panel-body').length

  if size > 20
    $('.chatbox .panel-body:first-child').remove()

  timestamp = moment.utc(data.timestamp).local().format('MMM D, H:mm');

  $('.chatbox').append ''+
    '<div class="panel-body">' +
      '<a href="/users/' + data.user + '" class="avatar-link">' +
        '<img class="img-circle" src="' + data.avatar + '"></img>' +
      '</a>' +
      '<div class="message">' +
        '<h5>' +
          '<a href="/users/' + data.user + '">' + data.username + '</a>' +
          '<span class="timestamp">' + timestamp + '</span>' +
        '</h5>' +
        '<p>' + data.content + '</p>' +
      '</div>' +
    '</div>'

  scroll_to_bottom()

add_member = (data) ->
  $('.nav-list ul').append('<li id="' + data.user + '"><a href="/users/' + data.user + '">' + data.username + '</a></li>')

remove_member = (data) ->
  $('.nav-list ul li#' + data.user).remove()

ready = ->
  if not $('#hashtag-id').length
    return

  scroll_to_bottom()

  uri = websocket_scheme + websocket_host
  ws = new WebSocket(uri)

  hashtag = $('#hashtag-id')[0].value
  user = $('#user-id')[0].value

  # page unload uses ajax unasync
  $.post "/update_last_visit/" + hashtag

  ws.onopen = ->
    ws.send JSON.stringify
      event: 'online'
      hashtag: hashtag
      user: user

  ws.onclose = ->
    input = $('#input-text')
    input.addClass('has-error')
    input.prop('disabled', true)
    input[0].value = 'Connection lost!'

  ws.onmessage = (message) ->
    data = JSON.parse message.data
    console.log(data)

    if data.event == 'message'
      add_message data
    else if data.event == 'online'
      set_all_offline()
      set_online id for id in data.onlines
      sort_members()
    else if data.event == 'join'
      add_member data
      sort_members()
    else if data.event == 'leave'
      remove_member data
    else if data.event == 'notification'
      count = $('.notif-count')
      t = Number(count.text())
      count.text(t + 1)
      if t == 0
        $('.notif-link').addClass('accent')

  $('#chat-send').on 'click', (event) ->
    event.preventDefault()

    text = $('#input-text')[0].value

    ws.send JSON.stringify
      event: 'message'
      content: text
      hashtag: hashtag
      user: user

    $('#input-text')[0].value = ''

  $(window).on 'beforeunload', ->
    $.ajax({
        type: 'POST',
        async: false,
        url: '/update_last_visit/' + $('#hashtag-id')[0].value
    })
    console.log "last visit updated"

$(document).ready(ready)
$(document).on('page:load', ready)
