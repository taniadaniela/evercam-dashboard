resizeWin = ->
  $(window).resize ->
    $('#evercam-video-section').css height: $(window).innerHeight()
    centerSignIn()
    return

centerSignIn = ->
  offset = ($(window).height() - $('.section-position').height()) / 2
  if $(window).height() > $('.section-position').height()
    # Center vertically in window
    $('.section-position').css "margin-top", offset

  widthset = ($(window).width() - $('.center-div').width()) / 2
  if $(window).width() > $('.center-div').width()
    # Center vertically in window
    $('.center-div').css "margin-left", widthset

validateUsernameEmail = (input_String, input_name) ->
  data = {}

  onError = (jqXHR, status, error) ->
    $("##{input_name}-error-block").css 'display', 'none'
    $("#signup-#{input_name} .#{input_name}-loading-icon").hide()
    $("##{input_name}-available").removeClass('hide')
    $("##{input_name}-not-available").addClass('hide')

  onSuccess = (response, status, jqXHR) ->
    $("##{input_name}-error-block").css 'display', 'block'
    $("#signup-#{input_name} .#{input_name}-loading-icon").hide()
    $("##{input_name}-not-available").removeClass('hide')
    $("##{input_name}-available").addClass('hide')

  settings =
    cache: false
    dataType: 'json'
    error: onError
    success: onSuccess
    type: 'POST'
    url: "#{Evercam.API_URL}users/exist/#{input_String}"
  $.ajax(settings)

getInputValue = ->
  $('#user_username').focusout ->
    input_value = $('#user_username').val()
    user_name = 'username'
    setTimeout (->
      if $('#signup-username').hasClass('has-error')
        hideUsernameValidationIcons()
        $('#username-error-block').css 'display', 'none'
      else
        hideUsernameValidationIcons()
        $('#signup-username .username-loading-icon').show()
        validateUsernameEmail(input_value, user_name)
    ), 100

  $('#user_email').focusout ->
    input_value = $('#user_email').val()
    user_email = 'email'
    setTimeout (->
      if $('#signup-email').hasClass('has-error')
        hideEmailValidationIcons()
        $('#email-error-block').css 'display', 'none'
      else
        hideEmailValidationIcons()
        $('#signup-email .email-loading-icon').show()
        validateUsernameEmail(input_value, user_email)
    ), 100

hideUsernameValidationIcons = ->
  $('#username-not-available').addClass('hide')
  $('#username-available').addClass('hide')

hideEmailValidationIcons = ->
  $('#email-not-available').addClass('hide')
  $('#email-available').addClass('hide')

window.initializeVideoBackground = ->
  centerSignIn()
  resizeWin()
  getInputValue()
