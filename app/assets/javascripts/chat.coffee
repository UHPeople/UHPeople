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

add_message = (data) ->
  highlight = ''
  if moment.utc(data.timestamp).isAfter(moment.utc($('#last-visit')[0].value))
    highlight = 'new_messages'

  $('.chatbox').append ''+
    '<div class="panel-body ' + highlight + ' ">' +
      '<a href="/users/' + data.user + '" class="avatar-link">' +
        '<img class="img-circle" src="' + data.avatar + '"></img>' +
      '</a>' +
      '<div class="message">' +
        '<h5>' +
          '<a href="/users/' + data.user + '">' + data.username + '</a>' +
          '<span class="timestamp">' + format_timestamp(data.timestamp) + '</span>' +
        '</h5>' +
        '<p>' + data.content + '</p>' +
      '</div>' +
    '</div>'


ready = ->
  if not $('#hashtag-id').length
    return
  else
    console.log('Chat page detected!')

  move_to_message()
  update_leave_button()

  hashtag = $('#hashtag-id')[0].value
  user = $('#user-id')[0].value

  members_list = $('ul.nav-list:not(.dropdown-menu)')
  members_list_dropdown = $('ul.nav-list.dropdown-menu')

  # page unload uses ajax unasync
  $.post "/update_last_visit/" + hashtag

  on_open = (socket) ->
    socket.send JSON.stringify
      event: 'online'
      hashtag: hashtag
      user: user

  on_close = ->
    input = $('#input-text')
    input.addClass('has-error')
    input.prop('disabled', true)
    input[0].value = 'Connection lost!'

  on_message = (data) ->
    add_message data
    scroll_to_bottom()

  on_online = (data) ->
    set_all_offline()
    set_online id for id in data.onlines
    sort_members members_list
    sort_members members_list_dropdown
    update_leave_button

  on_join = (data) ->
    add_member data
    sort_members members_list
    sort_members members_list_dropdown
    update_leave_button

  on_leave = (data) ->
    remove_member data
    update_leave_button

  on_messages = (data) ->
    add_multiple_messages data, add_message, true
    move_to_message()

  ws = create_websocket {
    'open': on_open,
    'close': on_close,
    'message': on_message,
    'online': on_online,
    'join': on_join,
    'leave': on_leave,
    'notification': on_notification,
    'messages': on_messages
  }

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

exports = this
exports.add_chat_message = add_message

$(document).ready(ready)
$(document).on('page:load', ready)
