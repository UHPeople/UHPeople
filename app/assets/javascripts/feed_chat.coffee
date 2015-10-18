# The click handler functions need the websocket
# null value will get overwritten by the ready() function
ws = null

add_unread = (data) ->
  console.log data.hashtag
  if !$('.interest-list-hashtag p a#' + data.hashtag).children().hasClass('unread')
      $('.interest-list-hashtag p a#' + data.hashtag).append '<span class="badge badge-success unread">1</span>'
  else
    $('.interest-list-hashtag p a#' + data.hashtag + ' .unread').text (i, t) ->
      if t > 0
        Number(t) + 1
      else
        ''

add_feed_message = (data) ->
  #highlight = ''
  #if moment.utc(data.timestamp).isAfter()
  #  highlight = 'new_messages'

  like_icon_liked = ''
  star = 'star_border'
  if data.current_user_likes
    like_icon_liked = 'like-icon-liked'
    star = 'star'

  $('#feed').prepend ''+
    '<div class="feed-chat-box" id="feed-' + data.id + '">' +
      '<a href="/users/' + data.user + '" class="avatar-link">' +
        '<img class="img-circle" src="' + data.avatar + '"></img>' +
      '</a>' +
      '<div class="message">' +
        '<h5>' +
          '<a href="/users/' + data.user + '">' + data.username + '</a>at ' +
          '<a href="/hashtags/' + data.hashtag_name + '">#' + data.hashtag_name + '</a>' +
          '<span class="timestamp" data-timestamp="' + data.timestamp + '">' +
            format_timestamp(data.timestamp) +
          '</span>' +
        '</h5>' +
        '<p>' +
          data.content +
          '<span class="space-left">' +
            '<span class="like-badge like-icon-color" id="tt' + data.id + '">' +
              data.likes +
            '</span>' +
            '<a class="send-hover like-this" href="#" id="feed-like-' + data.id + '">' +
              '<i class="material-icons md-15 like-icon like-icon-color ' + like_icon_liked + '">' + star + '</i>' +
            '</a>' +
          '</span>' +
        '</p>' +
      '</div>' +
    '</div>'

    add_mouseover_to_get_likers('tt', data.id)
    set_star_hover()

add_favourites_message = (data) ->
  if $('div.fav#box-' + data.hashtag + ' .panel-body').length >= 5
    $('div.fav#box-' + data.hashtag + ' .panel-body.fav:first').remove()

  like_icon_liked = ''
  star = 'star_border'
  if data.current_user_likes
    like_icon_liked = 'like-icon-liked'
    star = 'star'

  $('div.fav#box-' + data.hashtag).append ''+
    '<div class="panel-body fav" id="favourites-' + data.id + '">' +
      '<div class="favourites-chat-box">' +
        '<a href="/users/' + data.user + '" class="avatar-link">' +
          '<img class="img-circle" src="' + data.avatar + '"></img>' +
        '</a>' +
        '<div class="message">' +
          '<h5>' +
            '<a href="/users/' + data.user + '">' + data.username + '</a> ' +
            '<span class="timestamp" data-timestamp="' + data.timestamp + '">' +
              format_timestamp(data.timestamp) +
            '</span>' +
          '</h5>' +
          '<p>' +
            data.content +
            '<span class="space-left">' +
              '<span class="like-badge like-icon-color" id="fav-tt' + data.id + '">' +
                data.likes +
              '</span>' +
              '<a class="send-hover like-this" href="#" id="favourites-like-' + data.id + '">' +
                '<i class="material-icons md-15 like-icon like-icon-color ' + like_icon_liked + '">' + star + '</i>' +
              '</a>' +
            '</span>' +
          '</p>' +
        '</div>' +
      '</div>' +
    '</div>'

  add_mouseover_to_get_likers('fav-tt', data.id)

on_open = (socket) ->
  user = $('#user-id')[0].value

  socket.send JSON.stringify
    event: 'feed'
    user: user

  socket.send JSON.stringify
    event: 'favourites'
    user: user

on_message = (data) ->
  add_feed_message data
  add_favourites_message data

  add_unread data

  add_click_handler_to_likes('#feed-like-' + data.id, ws)
  add_click_handler_to_likes('#favourites-like-' + data.id, ws)

on_messages = (data) ->
  add_multiple_messages data, add_feed_message, false
  add_click_handler_to_likes('.feed-chat-box .like-this', ws)

on_favourites = (data) ->
  add_multiple_messages data, add_favourites_message, false
  add_click_handler_to_likes('.fav .like-this', ws)

like_both = (data) ->
  on_like(data, 'favourites-')
  on_like(data, 'feed-')

dislike_both = (data) ->
  on_dislike(data, 'favourites-')
  on_dislike(data, 'feed-')

ready = ->
  if not $('#feed').length
    return
  else
    console.log('Feed page detected!')

  ws = create_websocket {
    'open': on_open,
    'message': on_message,
    'notification': on_notification,
    'messages': on_messages,
    'like': like_both,
    'dislike': dislike_both,
    'favourites': on_favourites
  }

exports = this
exports.add_feed_message = add_feed_message
exports.add_favourites_message = add_favourites_message

$(document).ready(ready)
$(document).on('page:load', ready)
