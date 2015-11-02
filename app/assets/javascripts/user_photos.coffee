
startSpinner = ->
  $('.image-overlay').fadeIn()
  $('.absolut-center-spinner').fadeIn()

stopSpinner = ->
  $('.image-overlay').fadeOut()
  $('.absolut-center-spinner').fadeOut()

loadPhotoSection = (select = '', callback)->
  user_id = $('.photosection').attr('id')
  $('.photosection').load "/users/#{user_id}/photos/" + select, ->
    # load callback
    componentHandler.upgradeDom()
    stopSpinner()
    $('.image__show').click ->
      startSpinner()
      getAndShowImage $(this).attr('id'), select, callback

    if select.length # if on selection partial
      $('.image__select').click () ->
        if $(this).children().hasClass 'is-selected'
          $(this).children().removeClass 'is-selected'
        else
          $(this).children().addClass 'is-selected'

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
          loadPhotoSection(select, callback)

    if (callback?) then callback()

getAndShowImage = (id, select, callback) ->
  $.get('/photos/' + id
  ).done (data) ->
    $('.absolut-center-spinner').fadeOut()
    $('.image-overlay').append data
    setImageComponents(select, callback)

setImageComponents = (select, callback)->
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
        loadPhotoSection(select, callback)

  componentHandler.upgradeDom()

checkCheckboxes = ->
  checkboxes = $('.is-selected')
  checked_ids = []
  for image in checkboxes
    do ->
        $(image).removeClass('is-selected') # should empty selection on message send
        checked_ids.push $(image).attr('id')
  checked_ids

exports = this
exports.checkCheckboxes = checkCheckboxes

ready = ->
  # hijack the bitwise operator so we don't have to do a -1 comparison
  if !!~ $(location).attr('pathname').indexOf 'users'
    loadPhotoSection()
  else if $('#hashtag-id').length
    $('.add-photo-modal__open').click (event) ->
      event.preventDefault()
      loadPhotoSection 'select', ->
        $('.mdl-layout__header').css('z-index', '-3') # move navbar under modal
        $('.card-image.mdl-card .mdl-card__actions').show()
        $('.add-photos-to-message-card').fadeIn()

    # click handlers
    $('.add-photo-modal__close').click () ->
      $('.add-photos-to-message-card').fadeOut()
      $('.mdl-layout__header').css('z-index', '3')

    $('.add-photo-modal__send').click () ->
      $('#photo_ids').val(checkCheckboxes())
      $('.add-photos-to-message-card').fadeOut()
      $('.mdl-layout__header').css('z-index', '3')

$(document).ready(ready)
$(document).on('page:load', ready)
