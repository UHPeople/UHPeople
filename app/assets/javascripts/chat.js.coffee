ready = ->
  scheme = 'ws://'
  uri = scheme + window.document.location.host
  ws = new WebSocket(uri)

  if not $('#hashtag-id').length
    return
  
  hashtag = $('#hashtag-id')[0].value
  user = $('#user-id')[0].value

  # ws.send JSON.stringify(event: 'online', hashtag: hashtag, user: user)
  
  $('#chat-text').scrollTop $('#chat-text')[0].scrollHeight

  ws.onmessage = (message) ->
    data = JSON.parse(message.data)
    
    if data.hashtag != hashtag
      return
    
    $('#chat-text').append '<div class=\'panel-body\'><span class=\'chat-timestamp\'>' +
      data.timestamp + '</span> <span class=\'chat-name\'>' + data.user + '</span>: ' + data.content + '</div>'
    
    $('#chat-text').stop().animate {
      scrollTop: $('#chat-text')[0].scrollHeight
    }, 800
    
    return

  $('#input-form').on 'submit', (event) ->
    event.preventDefault()
    
    text = $('#input-text')[0].value

    ws.send JSON.stringify(
      event: 'message'
      content: text
      hashtag: hashtag
      user: user)

    $('#input-text')[0].value = ''
    return
  return

$(document).ready(ready)
$(document).on('page:load', ready)
