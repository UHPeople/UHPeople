
startSpinner = ->
  $('.image-overlay').fadeIn()
  $('.absolut-center-spinner').fadeIn()

stopSpinner = ->
  $('.image-overlay').fadeOut()
  $('.absolut-center-spinner').fadeOut()

setAddPhotoToMessageClickHandlers = (photosection) ->
  $(".add-photo-modal__open").click (event) ->
    event.preventDefault()
    $('.mdl-layout__header').css('z-index', '-3')
    $('.add-photos-to-message-card').fadeIn()
    loadPhotoSection(photosection)

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
        loadPhotoSection(photosection)

  $('.add-photo-modal__close').click () ->
    $('.add-photos-to-message-card').fadeOut()
    $('.mdl-layout__header').css('z-index', '3')

  $('.add-photo-modal__send').click () ->
    cf = addSelectedPhotosToInput(photosection)
    if cf.length
      $('.add-photos-to-message-card').fadeOut()
      $('.mdl-layout__header').css('z-index', '3')

setCoverPhotoModalClickHandlers = (photosection) ->
  $('.change-cover-modal__open').click (event) ->
    event.preventDefault()
    $('.edit-card').css('z-index', '1')
    $('.mdl-layout__header').css('z-index', '-3')
    $('.change-cover-card').fadeIn()
    loadPhotoSection(photosection)

  $('.change-cover-modal__close').click () ->
    $('.change-cover-card').fadeOut()
    $('.mdl-layout__header').css('z-index', '3')
    ('.edit-card').css('z-index', '9')

  $('.change-cover-modal__send').click () ->
    selectedhotos = $("#{photosection} .is-selected")
    if selectedhotos.length == 1
      $('#cover_photo').val(selectedhotos.attr('id'))
      $('.edit-card').css('z-index', '9')
      $('.change-cover-card').fadeOut()

loadPhotoSection = (photosection) ->
  user_id = $(photosection).attr('id')
  $(photosection).load "/users/#{user_id}/photos/select", ->
    # photosection load callback

    $("#{photosection} a.image__select").click () ->
      if $(this).children().hasClass 'is-selected'
        $(this).children().removeClass 'is-selected'
      else
        if photosection is '.change-cover-photosection'
          #single selection
          $('.change-cover-photosection a.image__select').children().removeClass('is-selected')
        $(this).children().addClass 'is-selected'

addSelectedPhotosToInput = (photosection) ->
  selectedhotos = $("#{photosection} .is-selected")
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
    setAddPhotoToMessageClickHandlers('.photosection')
    setCoverPhotoModalClickHandlers('.change-cover-photosection')

$(document).ready(ready)
$(document).on('page:load', ready)
