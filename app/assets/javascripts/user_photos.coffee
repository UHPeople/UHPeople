
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

addSelectedPhotosToInput = ->
  selectedhotos = $('.is-selected')
  for image in selectedhotos
    do ->
      img_url = $(image).css('background-image')
      img_id = $(image).attr 'id'

      $('.added-image-area').append("""
        <div class="added-image-container" id="#{img_id}">
          <div class="added-image" style="background-image: #{img_url};"></div>
          <div class="clear-image">
            <i class="material-icons">clear</i>
          </div>
        </div>""")

      $("##{img_id}.added-image-container").hover( ->
        $(this).children('.clear-image').show()
        $(this).children('.added-image').css({
          '-webkit-filter': 'brightness(50%)',
          '-moz-filter': 'brightness(50%)',
          '-o-filter': 'brightness(50%)',
          '-ms-filter': 'brightness(50%)',
          'filter': 'brightness(50%)',
        })
      , ->
        $(this).children('.clear-image').hide()
        $(this).children('.added-image').css({
          '-webkit-filter': 'brightness(100%)',
          '-moz-filter': 'brightness(100%)',
          '-o-filter': 'brightness(100%)',
          '-ms-filter': 'brightness(100%)',
          'filter': 'brightness(100%)',
        })
      )
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
      cf = addSelectedPhotosToInput()
      if cf.length
        $('.add-photos-to-message-card').fadeOut()
        $('.mdl-layout__header').css('z-index', '3')

$(document).ready(ready)
$(document).on('page:load', ready)
