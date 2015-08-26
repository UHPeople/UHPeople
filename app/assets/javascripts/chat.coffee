set_online = (id) ->
  $('.nav-list li.member-' + id).addClass('online')

set_all_offline = (id) ->
  $('.nav-list li').removeClass('online')

add_member = (data) ->
  element = ''+
    '<li class="member-' + data.user + '">'+
      '<a href="/users/' + data.user + '">' + data.username + '</a>' +
    '</li>'

  $('.nav-list').append(element)

remove_member = (data) ->
  $('.nav-list li.member-' + data.user).remove()

scroll_to_bottom = ->
  chatbox = $('.chatbox')
  height = chatbox[0].scrollHeight

  if ((height - chatbox[0].scrollTop) < 600)
    chatbox.stop().animate {
      scrollTop: height
    }, 800

move_to_message = ->
  if !(window.location.hash)
    $('.chatbox')[0].scrollTop = $('.chatbox')[0].scrollHeight
  else
    message_id = window.location.hash
    $('.panel-body'+message_id).addClass('unread_messages')

compare_text = (a, b) ->
  $(a).text().toUpperCase().localeCompare($(b).text().toUpperCase())

compare_status = (a, b) ->
  if (a.classList.contains("dropdown-header"))
    return -1
  else if (b.classList.contains("dropdown-header"))
    return 1

  if (a.classList.contains("online"))
    if (b.classList.contains("online"))
      return 0
    else
      return -1
  else if (b.classList.contains("online"))
    return 1
  else
    return 0

sort_members = (list) ->
  items = list.children('li').get()
  items.sort (a, b) ->
    if a.classList != b.classList
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

ready = ->
  if not $('#hashtag-id').length
    return

  move_to_message()

  uri = websocket_scheme + websocket_host
  ws = new WebSocket(uri)

  hashtag = $('#hashtag-id')[0].value
  user = $('#user-id')[0].value

  members_list = $('ul.nav-list:not(.dropdown-menu)')
  members_list_dropdown = $('ul.nav-list.dropdown-menu')

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
      sort_members(members_list)
      sort_members(members_list_dropdown)
    else if data.event == 'join'
      add_member data
      sort_members(members_list)
      sort_members(members_list_dropdown)
    else if data.event == 'leave'
      remove_member data
    else if data.event == 'notification'
      count = $('.notif-count')
      t = Number(count.text())
      if t == 0
        $('.notif-count').append( "<span class='badge badge-success'>1</span>" );
      else
        $('.notif-count .badge').text(t + 1)
    else if data.event == 'like'
      console.log(data.message)
      add_like data

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

  $('.like-this').click ()->
    event.preventDefault()
    $.ajax({
      type: 'POST',
      async: false,
      url: '/like_this/' + this.id
    })
    console.log('like send to ' + this.id)


$(document).ready(ready)
$(document).on('page:load', ready)
