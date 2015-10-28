
toggleSpinner = ->
  unless $('.absolut-center-spinner').is(":visible")
    $('.image-overlay').fadeIn()
    $('.absolut-center-spinner').fadeIn()
  else
    $('.image-overlay').fadeOut()
    $('.absolut-center-spinner').fadeOut()

loadPhotoSection = ->
  toggleSpinner()
  user_id = $('h2.mdl-typography--text-center').attr('id')
  $('.photosection').load "/users/#{user_id}/photos", ->
    # load callback
    toggleSpinner()
    $('.image__show').click ->
      toggleSpinner()
      getAndShowImage $(this).attr('id')

    $('.fab_add_button').click (event) ->
      event.preventDefault()
      $('#image').click()

    $('#image').change ->
      toggleSpinner()
      $(this).parent().ajaxSubmit
        beforeSubmit: (a, f, o) ->
          o.dataType = 'json'
        complete: (XMLHttpRequest, textStatus) ->
          # console.log XMLHttpRequest.responseJSON.message
          toggleSpinner()
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

ready = ->
  unless $(location).attr('pathname').indexOf('users') > -1
   return
  else
  loadPhotoSection()

$(document).ready(ready)
$(document).on('page:load', ready)
