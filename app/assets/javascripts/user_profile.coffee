
startSpinner = ->
  $('.image-overlay').fadeIn()
  $('.absolut-center-spinner').fadeIn()

stopSpinner = ->
    $('.image-overlay').fadeOut()
    $('.absolut-center-spinner').fadeOut()

loadPhotoSection = ->
  user_id = $('h2.mdl-typography--text-center').attr('id')
  $('.photosection').load "/users/#{user_id}/photos", ->
    # load callback
    componentHandler.upgradeDom()
    stopSpinner()
    $('.image__show').click ->
      startSpinner()
      getAndShowImage $(this).attr('id')

    $('.fab_add_button').click (event) ->
      event.preventDefault()
      $('#image').click()

    $('#image').change ->
      startSpinner()
      $(this).parent().ajaxSubmit
        beforeSubmit: (a, f, o) ->
          o.dataType = 'json'
        complete: (XMLHttpRequest, textStatus) ->
          # console.log XMLHttpRequest.responseJSON.message
          stopSpinner()
          loadPhotoSection()

getAndShowImage = (id) ->
  $.get('/photos/' + id, ->
  ).done (data) ->
    $('.absolut-center-spinner').fadeOut()
    $('.image-overlay').append data
    setImageComponents()

setImageComponents = ->
  $('.image__close').click ->
    $('.overlay-card').remove()
    $('.image-overlay').fadeOut()

  $('.image__delete').click (event) ->
    event.preventDefault()
    $('.overlay-card').remove()
    $('.image-overlay').fadeOut()
    $.ajax
      url: '/photos/' + $(this).attr('id')
      type: 'DELETE'
      success: (result) ->
        loadPhotoSection()

  componentHandler.upgradeDom()

checkCheckboxes = ->
  boxes = $('input[type=checkbox]')
  checked_ids = []
  for box in boxes
    do ->
      if $(box).is(':checked')
        $(box).parent().removeClass('is-checked')
        checked_ids.push $(box).attr('id').split('-')[1]
  checked_ids

exports = this
exports.checkCheckboxes = checkCheckboxes

ready = ->
  unless $(location).attr('pathname').indexOf('users') > -1
   return
  else
  loadPhotoSection()

$(document).ready(ready)
$(document).on('page:load', ready)
