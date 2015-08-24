add_message = (data) ->
  size = $('div.panel.fav#box-' + data.hashtag + ' .panel-body').length

  if size >= 5
    $('div.panel.fav#box-' + data.hashtag + ' .panel-body.fav:first').remove()

  timestamp = moment.utc(data.timestamp).local().format('MMM D, H:mm');

  $('td a#' + data.hashtag + ' .unread').text (i, t) ->
    if t > 1
      Number(t) + 1
    else
      setupNoNotif()
      ''

  $('#feed').prepend ''+
    '<div class="feed-chat-box">' +
      '<a href="/users/' + data.user + '" class="avatar-link">' +
        '<img class="img-circle" src="' + data.avatar + '"></img>' +
      '</a>' +
      '<div class="message">' +
        '<h5>' +
          '<a href="/users/' + data.user + '">' + data.username + '</a>at ' +
          '<a href="/hashtags/' + data.hashtag_name + '">' + data.hashtag_name + '</a>' +
          '<span class="timestamp">' + timestamp + '</span>' +
        '</h5>' +
        '<p>' + data.content + '</p>' +
      '</div>' +
    '</div>'

  $('div.panel.fav#box-' + data.hashtag).append ''+
    '<div class="panel-body fav">' +
      '<div class="favourites-chat-box">' +
        '<a href="/users/' + data.user + '" class="avatar-link">' +
          '<img class="img-circle" src="' + data.avatar + '"></img>' +
        '</a>' +
        '<div class="message">' +
          '<h5>' +
            '<a href="/users/' + data.user + '">' + data.username + '</a>at ' +
            '<a href="/hashtags/' + data.hashtag_name + '">' + data.hashtag_name + '</a>' +
            '<br/>' +
            '<span class="timestamp">' + timestamp + '</span>' +
          '</h5>' +
          '<p>' + data.content + '</p>' +
        '</div>' +
      '</div>' +
    '</div>'

  $('#masonry-container').masonry()

ready = ->
  if not $('#feed').length
    return

  uri = websocket_scheme + websocket_host
  ws = new WebSocket(uri)

  user = $('#user-id')[0].value

  ws.onopen = ->
    ws.send JSON.stringify
      event: 'feed'
      user: user

  ws.onmessage = (message) ->
    data = JSON.parse message.data

    if data.event == 'message'
      add_message data
    else if data.event == 'notification'
      count = $('.notif-count')
      t = Number(count.text())
      count.text(t + 1)
      if t == 0
        $('.notif-link').addClass('accent')

$(document).ready(ready)
$(document).on('page:load', ready)
