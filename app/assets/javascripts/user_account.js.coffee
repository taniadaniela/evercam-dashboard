handleEditable = ->
  $('.makeNonEditable').on 'click', ->
    $('#userProfile input:text').attr 'readonly', 'readonly'
    $('select').attr 'disabled', 'disabled'
    return
  $('.makeEditable').on 'click', ->
    $('#userProfile input:text').removeAttr 'readonly'
    $('select').removeAttr 'disabled'
    return

showHideMessage = ->
  $('#hide').click ->
    $('.hide-p').fadeOut()

  $('#hide-2').click ->
    $('.hide-p').fadeOut()

  $('#show').click ->
    $('.hide-p').fadeIn()


handlePasswordChange = ->
  $('#change-password').on 'click', ->
    if $('#new-password').val() != $('#password_again').val()
      $('#wrong-confirm-password').show()
      $('#password_again').addClass 'border-red'
      return false
    $('#wrong-confirm-password').hide()
    $('#password_again').removeClass 'border-red'
    true

window.initializeUserAccount = ->
  $.validate()
  Metronic.init()
  Layout.init()
  QuickSidebar.init()
  Notification.init(".bb-alert")
  handleEditable()
  showHideMessage()
  handlePasswordChange()

