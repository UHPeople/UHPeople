
startSpinner = ->
  $('.image-overlay').fadeIn()
  $('.absolut-center-spinner').fadeIn()

stopSpinner = ->
  $('.image-overlay').fadeOut()
  $('.absolut-center-spinner').fadeOut()

setAddPhotoToMessageClickHandlers = (multiple)->
  $('.add-photo-modal__open').click (event) ->
    event.preventDefault()
    $('.mdl-layout__header').css('z-index', '-3')
    $('.add-photos-to-message-card').fadeIn()
    loadPhotoSection(multiple)

  $('.fab_add_button').click (event) ->
    event.preventDefault()
    $('#image').click()

  # image input change function
  $('#image').change ->
    startSpinner()
    $(this).parent().ajaxSubmit
      beforeSubmit: (a, f, o) ->
        o.dataType = 'json'
      complete: (XMLHttpRequest, textStatus) ->
        # console.log XMLHttpRequest.responseJSON.message
        stopSpinner()
        loadPhotoSection(multiple)

  $('.add-photo-modal__close').click () ->
    $('#add-photo')[0].reset();
    $('.add-photos-to-message-card').fadeOut()
    $('.mdl-layout__header').css('z-index', '3')

  $('.add-photo-modal__send').click () ->
    cf = addSelectedPhotosToInput()
    if cf.length
      $('.add-photos-to-message-card').fadeOut()
      $('.mdl-layout__header').css('z-index', '3')

loadPhotoSection = (multiple)->
  user_id = $('.photosection').attr('id')
  $('.photosection').load "/users/#{user_id}/photos/select", ->
    # photosection load callback

    $('.image__select').click () ->
      if $(this).children().hasClass 'is-selected'
        $(this).children().removeClass 'is-selected'
      else
        if not multiple then $('.image__select').children().removeClass('is-selected')
        $(this).children().addClass 'is-selected'

addSelectedPhotosToInput = ->
  selectedhotos = $('.is-selected')
  for image in selectedhotos
    do ->
      img_url = $(image).css('background-image')
      img_id = $(image).attr 'id'

      $('.added-image-area').append """
          <div class="added-image-container" id="#{img_id}">
            <div class="added-image" style="background-image: #{img_url};"></div>
            <div class="clear-image">
              <i class="material-icons">clear</i>
            </div>
          </div>
        """

      $("##{img_id}.added-image-container").hover ->
        $(this).children('.clear-image').show()
        $(this).children('.added-image').css
          '-webkit-filter': 'brightness(50%)'
          '-moz-filter': 'brightness(50%)'
          '-o-filter': 'brightness(50%)'
          '-ms-filter': 'brightness(50%)'
          'filter': 'brightness(50%)'
      , ->
        $(this).children('.clear-image').hide()
        $(this).children('.added-image').css
          '-webkit-filter': 'brightness(100%)'
          '-moz-filter': 'brightness(100%)'
          '-o-filter': 'brightness(100%)'
          '-ms-filter': 'brightness(100%)'
          'filter': 'brightness(100%)'

      $("##{img_id}.added-image-container").click ->
        $(this).remove()

selectedPhotosToArrayAndEmpty = ->
  added_images = $('.added-image-area').children()
  added_ids = []
  for image in added_images
    do ->
      id = $(image).attr('id')
      if id not in added_ids
        added_ids.push id
  added_images.remove()
  added_ids

exports = this
exports.selectedPhotosToArrayAndEmpty = selectedPhotosToArrayAndEmpty

ready = ->
  # hijack the bitwise operator so we don't have to do a -1 comparison
  if !!~ $(location).attr('pathname').indexOf 'hashtag'
    setAddPhotoToMessageClickHandlers(true)

$(document).ready(ready)
$(document).on('page:load', ready)
