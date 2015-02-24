set_online = (id) ->
  $('li#' + id).append ''

add_message = (data) ->
  hashtag = $('#hashtag-id')[0].value

  if data.hashtag != hashtag
    return
  
  $('#chat-text').append '<div class=\'panel-body\'><span class=\'chat-timestamp\'>' +
    data.timestamp + '</span> <span class=\'chat-name\'>' + data.user + '</span>: ' + data.content + '</div>'
  
  $('#chat-text').stop().animate {
    scrollTop: $('#chat-text')[0].scrollHeight
  }, 800

exports = this
exports.add_message = add_message
exports.set_online = set_online

ready = ->
  scheme = 'ws://'
  uri = scheme + window.document.location.host
  ws = new WebSocket(uri)

  exports.ws = ws

  if not $('#hashtag-id').length
    return
  
  hashtag = $('#hashtag-id')[0].value
  user = $('#user-id')[0].value
  
  $('#chat-text').scrollTop $('#chat-text')[0].scrollHeight

  ws.onopen = ->
    console.log("Connection Opened")
    #ws.send JSON.stringify(event: 'online', hashtag: hashtag, user: user)

  ws.onmessage = (message) ->
    console.log(message)

    data = JSON.parse(message.data)

    if data.event == 'message'
      add_message(data)
    else if data.event == 'online'
      set_online id for user in data.onlines

  ws.onclose = ->
    console.log("Connection Closed")

  $('#input-form').on 'submit', (event) ->
    event.preventDefault()
    
    text = $('#input-text')[0].value

    ws.send JSON.stringify(
      event: 'message'
      content: text
      hashtag: hashtag
      user: user)

    $('#input-text')[0].value = ''

$(document).ready(ready)
$(document).on('page:load', ready)
