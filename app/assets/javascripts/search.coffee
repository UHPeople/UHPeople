normalize = (str) ->
  if /^#[^#]*$/.test(str)
    return str.substring(1)
  str

users = new Bloodhound(
  datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name')
  queryTokenizer: Bloodhound.tokenizers.whitespace
  prefetch:
    url: '/users/'
    ttl: 1)

hashtags = new Bloodhound(
  datumTokenizer: Bloodhound.tokenizers.obj.whitespace('tag')
  queryTokenizer: (query) ->
    Bloodhound.tokenizers.whitespace normalize(query)
  prefetch:
    url: '/hashtags/'
    ttl: 1)

users_mentions = new Bloodhound(
  datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name')
  queryTokenizer: (query) ->
    matches = query.toLowerCase().match(/@\w+/g)
    matches = if (matches == null) then [] else matches
    matches = (m.substr(1) for m in matches)
    return matches
  prefetch:
    url: '/users/'
    ttl: 1)

addNotice = (name, avatar) ->
  $('.invite-modal').append '' +
    '<div class="alert alert-success alert-dismissible invite-notice" role="alert" style="display: none;">' +
      '<button type="button" class="close" data-dismiss="alert" aria-label="Close">' +
        '<span aria-hidden="true">&times;</span>' +
      '</button>' +
      '<div>' +
        '<span>' + name + ' invited</span>' +
        '<a href="#"><img class="img-circle" src="' + avatar + '"></img></a>' +
      '</div>' +
    '</div>'

  $('.invite-notice').slideDown 'slow'

  $('.invite-notice button').on 'click', ->
    $(this).parent().hide 'slow'

clearInviteBox = ->
  $('form#invite-form span span.glyphicon').remove()
  $('form#invite-form').parent().removeClass 'has-success'
  $('form#invite-form').parent().removeClass 'has-error'
  $('form#invite-form span input#user').val ''

  return

makeSexy = ->
  input = $('form#invite-form span input#user')
  form = $('form#invite-form')

  input.click ->
    clearInviteBox()

  form.submit ->
    input.blur()
    $.ajax(
      type: 'POST'
      url: form.attr('action')
      data: form.serialize()
      dataType: 'JSON'
    ).done((json) ->
      form.children('.input-group').children('.twitter-typeahead').append '<span class="glyphicon glyphicon-ok form-control-feedback" aria-hidden="true"></span>'
      form.parent().addClass 'has-success'
      addNotice json['name'], json['avatar']
    ).fail ->
      form.children('.input-group').children('.twitter-typeahead').append '<span class="glyphicon glyphicon-remove form-control-feedback" aria-hidden="true"></span>'
      form.parent().addClass 'has-error'
    false

send = (name) ->
  $('form#invite-form span input#user').text name
  $('form#invite-form').submit()

$(document).ready ->
  # users.clearPrefetchCache()

  users.initialize()
  hashtags.initialize()

  $('.typeahead').typeahead({
    highlight: true
  }, {
    name: 'hashtags'
    displayKey: 'tag'
    source: hashtags.ttAdapter()
    templates: suggestion: Handlebars.compile(
      '<a href="/hashtags/{{tag}}">' +
        '<div>' +
          '<span>#{{tag}}</span>' +
         ' <span class="search-small-font">{{topic}}</span>' +
        '</div>' +
        '</a>')
  }, {
    name: 'users'
    displayKey: 'name'
    source: users.ttAdapter()
    templates: suggestion: Handlebars.compile(
      '<a href="/users/{{id}}">' +
        '<div>' +
          '<span>{{name}}</span>' +
          ' <span class="search-small-font">{{about}}</span>' +
          '<img class="img-circle" src="{{avatar}}"></img>' +
        '</div>' +
      '</a>')
  }).on('typeahead:selected', (obj, datum) ->
    url = window.location.origin

    if datum.tag != undefined
      url = url + '/hashtags/' + datum.tag
    else
      url = url + '/users/' + datum.id

    window.location.href = url
  )

$(document).ready ->
  if $('.typeahead-invite').length == 0
    return

  # users.initialize()

  $('.typeahead-invite').typeahead {
    highlight: true
  }, {
    name: 'users'
    displayKey: 'name'
    source: users.ttAdapter()
    templates: suggestion: Handlebars.compile(
      '<div onclick="send({{name}});">' +
        '<span>{{name}}</span>' +
        '<img class="img-circle" src="{{avatar}}"></img>' +
      '</div>')
  }

  makeSexy()

$(document).ready ->
  if $('.typeahead-add').length == 0
    return

  # hashtags.initialize()

  $('.typeahead-add').typeahead {
    highlight: true
  }, {
    name: 'hashtags'
    displayKey: 'tag'
    source: hashtags.ttAdapter()
    templates: suggestion: Handlebars.compile(
      '<a href="/hashtags/{{tag}}">' +
        '<div><span>#{{tag}}</span></div>' +
      '</a>')
  }

$(document).ready ->
  users_mentions.initialize()

  $('.typeahead-mention').typeahead {
    highlight: true
  }, {
    name: 'users'
    displayKey: 'name'
    source: users_mentions.ttAdapter()
  }
