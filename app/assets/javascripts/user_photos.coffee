
startSpinner = ->
  $('.image-overlay').fadeIn()
  $('.absolut-center-spinner').fadeIn()

stopSpinner = ->
  $('.image-overlay').fadeOut()
  $('.absolut-center-spinner').fadeOut()

loadPhotoSection = (callback)->
  user_id = $('.photosection').attr('id')
  $('.photosection').load "/users/#{user_id}/photos", ->
    # load callback
    componentHandler.upgradeDom()
    stopSpinner()
    $('.image__show').click ->
      startSpinner()
      getAndShowImage $(this).attr('id'), callback

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
          loadPhotoSection(callback)
          
    if (callback?) then callback()

getAndShowImage = (id, callback) ->
  $.get('/photos/' + id, ->
  ).done (data) ->
    $('.absolut-center-spinner').fadeOut()
    $('.image-overlay').append data
    setImageComponents(callback)

setImageComponents = (callback)->
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
        loadPhotoSection(callback)

  componentHandler.upgradeDom()

checkCheckboxes = ->
  checkboxes = $('input[type=checkbox]')
  checked_ids = []
  for box in checkboxes
    do ->
      if $(box).is(':checked')
        $(box).parent().removeClass('is-checked')
        checked_ids.push $(box).attr('id').split('-')[1]
  checked_ids

exports = this
exports.checkCheckboxes = checkCheckboxes

ready = ->
  if $(location).attr('pathname').indexOf('users') > -1 #what if hashtagname contains 'users'
    loadPhotoSection()
  if $('#hashtag-id').length
    $('.add-photo-modal__open').click (event) ->
      event.preventDefault()
      loadPhotoSection ->
        $('.mdl-layout__header').css('z-index', '-3')
        $('.card-image.mdl-card .mdl-card__actions').show()
        $('.add-photos-to-message-card').fadeIn()

    $('.add-photo-modal__close').click (event) ->
      $('.add-photos-to-message-card').fadeOut()
      $('.mdl-layout__header').css('z-index', '3')


    $('.add-photo-modal__send').click (event) ->
      $('#photo_ids').val(checkCheckboxes())
      $('.add-photos-to-message-card').fadeOut()
      $('.mdl-layout__header').css('z-index', '3')

$(document).ready(ready)
$(document).on('page:load', ready)
