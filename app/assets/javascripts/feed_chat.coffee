# The click handler functions need the websocket
# null value will get overwritten by the ready() function
ws = null

add_unread = (data) ->
  badge = $('#' + data.hashtag + ' .mdl-badge')
  badge.attr('data-badge', Number(badge.attr('data-badge'))+1)

add_feed_message = (data) ->
  #highlight = ''
  #if moment.utc(data.timestamp).isAfter()
  #  highlight = 'new_messages'

  like_icon_liked = ''
  star = 'star_border'
  if $('#user-name').val() in data.likes
    like_icon_liked = 'like-icon-liked'
    star = 'star'

  photos = construct_photo_message data.photos

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
        '</h5>' + photos +
        '<p>' +
          data.content +
          '<span class="space-left">' +
            '<span class="like-badge like-icon-color" id="tt' + data.id + '">' +
              data.likes.length +
            '</span>' +
            '<a class="send-hover like-this" href="#" id="feed-like-' + data.id + '">' +
              '<i class="material-icons md-15 like-icon like-icon-color ' + like_icon_liked + '">' + star + '</i>' +
            '</a>' +
          '</span>' +
        '</p>' +
      '</div>' +
    '</div>'

    add_mouseover_to_show_likers('tt' + data.id, data.likes)
    set_star_hover()

add_favourites_message = (data) ->
  if $('div.fav#box-' + data.hashtag + ' .panel-body').length >= 5
    $('div.fav#box-' + data.hashtag + ' .panel-body.fav:first').remove()

  like_icon_liked = ''
  star = 'star_border'
  if $('#user-name').val() in data.likes
    like_icon_liked = 'like-icon-liked'
    star = 'star'

  photos = construct_photo_message data.photos

  $(''+
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
          '</h5>' + photos +
          '<p>' +
            data.content +
            '<span class="space-left">' +
              '<span class="like-badge like-icon-color" id="fav-tt' + data.id + '">' +
                data.likes.length +
              '</span>' +
              '<a class="send-hover like-this" href="#" id="favourites-like-' + data.id + '">' +
                '<i class="material-icons md-15 like-icon like-icon-color ' + like_icon_liked + '">' + star + '</i>' +
              '</a>' +
            '</span>' +
          '</p>' +
        '</div>' +
      '</div>' +
    '</div>').insertAfter('div.fav#box-' + data.hashtag + ' .mdl-card__title')

  add_mouseover_to_show_likers('fav-tt' + data.id, data.likes)

on_open = (socket) ->
  user = $('#user-id')[0].value

  socket.send JSON.stringify
    event: 'feed'

  socket.send JSON.stringify
    event: 'favourites'

on_message = (data) ->
  add_feed_message data
  add_favourites_message data

  add_unread data

  add_click_handler_to_likes('#feed-like-' + data.id, ws)
  add_click_handler_to_likes('#favourites-like-' + data.id, ws)

on_feed = (data) ->
  add_multiple_messages data, add_feed_message, false
  add_click_handler_to_likes('.feed-chat-box .like-this', ws)

on_favourites = (data) ->
  add_multiple_messages data, add_favourites_message, false
  add_click_handler_to_likes('.fav .like-this', ws)

like_both = (data) ->
  on_like(data, 'fav-tt')
  on_like(data, 'tt')

dislike_both = (data) ->
  on_dislike(data, 'fav-tt')
  on_dislike(data, 'tt')

ready = ->
  if not $('#feed').length
    return
  else
    console.log('Feed page detected!')

  ws = create_websocket {
    'open': on_open,
    'message': on_message,
    'feed': on_feed,
    'like': like_both,
    'dislike': dislike_both,
    'favourites': on_favourites,
    'mention': on_notification,
    'invite': on_notification,
    'topic': on_notification
  }

exports = this
exports.add_feed_message = add_feed_message
exports.add_favourites_message = add_favourites_message

$(document).ready(ready)
$(document).on('page:load', ready)
