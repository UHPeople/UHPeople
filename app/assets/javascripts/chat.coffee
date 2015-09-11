update_leave_button = () ->
  if $('.nav-list li').size() <= 3
    $('.leave-button').data('confirm', 'Are you sure you want to leave this channel? ' +
      'You are the last person on this channel. ' +
      'After you leave the channel and all its messages will be deleted.')
  else
    $('.leave-button').data('confirm', 'Are you sure you want to leave this channel?')

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

format_timestamp = (timestamp) ->
  if !moment.isMoment(timestamp)
    timestamp = moment.utc(timestamp)
  timestamp.local().format('MMM D, H:mm')

add_message = (data) ->
  timestamp = format_timestamp data.timestamp
  last_visit = format_timestamp $('#last-visit')[0].value

  highlight = ''
  if moment.utc(data.timestamp).isAfter(moment.utc($('#last-visit')[0].value))
    highlight = 'new_messages'

  like_icon_liked = ''
  star = 'star_border'
  if data.current_user_likes
    like_icon_liked = 'like-icon-liked'
    star = 'star'

  $('.chatbox').append ''+
    '<div class="panel-body ' + highlight + '" id="' + data.id + '">' +
      '<a href="/users/' + data.user + '" class="avatar-link">' +
        '<img class="img-circle" src="' + data.avatar + '"></img>' +
      '</a>' +
      '<div class="message">' +
        '<h5>' +
          '<a href="/users/' + data.user + '">' + data.username + '</a>' +
          '<span class="timestamp">' + timestamp + '</span>' +
        '</h5>' +
        '<p>' + data.content +
          '<span class="space-left">' +
            '<span class="like-badge like-icon-color">' +
              data.likes +
            '</span>' +
            '<a class="send-hover like-this" href="#" id="like-' + data.id + '" onclick="click_like(event, ' + data.id + ');">' +
              '<i class="material-icons md-18 like-icon like-icon-color ' + like_icon_liked + '">' + star + '</i>' +
            '</a>' +
          '</span>' +
        '</p>' +
      '</div>' +
    '</div>'

    set_star_hover()

ws = ->

click_like = ( e, message_id )->
  e.preventDefault()
  change_thumb $('#' + message_id + ' i')
  ws.send_like( message_id )  

change_thumb = (t) ->
  if $(t).hasClass( "like-icon-liked" )
    $(t).removeClass( "like-icon-liked" )
    $(t).text 'star_border'
  else
    $(t).addClass( "like-icon-liked" )
    $(t).text 'star'

add_notification = ->
  count = $('.notif-count')
  t = Number(count.text())
  if t == 0
    $('.notif-count').append("<span class='badge badge-success'>1</span>");
  else
    $('.notif-count .badge').text(t + 1)

add_multiple_messages = (data) ->
  last_visit = moment.utc($('#last-visit')[0].value)
  markerDrawn = false
  for message in data.messages
    if (!markerDrawn and moment.utc(message.timestamp).isAfter(last_visit))
      $('.chatbox').append ''+
        '<div class="line text-center">' +
          '<span>Since<span class="timestamp">' + format_timestamp(last_visit) + '</span></span>'+
        '</div>'
      markerDrawn = true
    add_message message
  move_to_message()

exports = this
exports.add_message = add_message
exports.add_multiple_messages = add_multiple_messages
exports.click_like = click_like

add_like = (data) ->
  count = $('#' + data.message + ' .like-badge')
  count.text(Number(count.text()) + 1)

remove_like = (data) ->
  count = $('#' + data.message + ' .like-badge')
  count.text(Number(count.text()) - 1)

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

add_notification = ->
  count = $('.notif-count')
  t = Number(count.text())
  if t == 0
    $('.notif-count').append("<span class='badge badge-success'>1</span>")
  else
    $('.notif-count .badge').text(t + 1)

ready = ->
  if not $('#hashtag-id').length
    return

  move_to_message()
  update_leave_button()

  uri = websocket_scheme + websocket_host
  ws = new WebSocket(uri)

  hashtag = $('#hashtag-id')[0].value
  user = $('#user-id')[0].value

  members_list = $('ul.nav-list:not(.dropdown-menu)')
  members_list_dropdown = $('ul.nav-list.dropdown-menu')

  # page unload uses ajax unasync
  #$.post "/update_last_visit/" + hashtag

  send = ->
    console.log 'asdadskj'

  ws.send_like = (message)->
    ws.send JSON.stringify
      event: 'like'
      user: user
      hashtag: hashtag
      message: message


  ws.onopen = ->
    ws.send JSON.stringify
      event: 'online'
      hashtag: hashtag
      user: user

    ws.send JSON.stringify
      event: 'messages'
      hashtag: hashtag
      user: user
      from: 0
      to: 20

  ws.onclose = ->
    input = $('#input-text')
    input.addClass('has-error')
    input.prop('disabled', true)
    input[0].value = 'Connection lost!'

  ws.onmessage = (message) ->
    data = JSON.parse message.data

    if data.event == 'message'
      add_message data
      scroll_to_bottom()
    else if data.event == 'online'
      set_all_offline()
      set_online id for id in data.onlines
      sort_members members_list
      sort_members members_list_dropdown
      update_leave_button
    else if data.event == 'join'
      add_member data
      sort_members members_list
      sort_members members_list_dropdown
      update_leave_button
    else if data.event == 'leave'
      remove_member data
      update_leave_button
    else if data.event == 'notification'
      add_notification
    else if data.event == 'like'
      add_like data
    else if data.event == 'dislike'
      remove_like data
    else if data.event == 'messages'
      add_multiple_messages data

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
    console.log ""

$(document).ready(ready)
$(document).on('page:load', ready)
