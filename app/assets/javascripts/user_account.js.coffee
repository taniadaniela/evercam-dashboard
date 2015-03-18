showHideMessage = ->
  $('#hide').click ->
    $('.hide-p').fadeOut()

  $('#hide-2').click ->
    $('.hide-p').fadeOut()

  $('.form-control').focus ->
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

$(window, document, undefined).ready ->
wskCheckbox = do ->
  wskCheckboxes = []
  SPACE_KEY = 32

  addEventHandler = (elem, eventType, handler) ->
    if elem.addEventListener
      elem.addEventListener eventType, handler, false
    else if elem.attachEvent
      elem.attachEvent 'on' + eventType, handler
    return

  clickHandler = (e) ->
    e.stopPropagation()
    if @className.indexOf('checked') < 0
      @className += ' checked'
    else
      @className = 'chk-span'
    return

  keyHandler = (e) ->
    e.stopPropagation()
    if e.keyCode == SPACE_KEY
      clickHandler.call this, e
      # Also update the checkbox state.
      cbox = document.getElementById(@parentNode.getAttribute('for'))
      cbox.checked = !cbox.checked
    return

  clickHandlerLabel = (e) ->
    id = @getAttribute('for')
    i = wskCheckboxes.length
    while i--
      if wskCheckboxes[i].id == id
        if wskCheckboxes[i].checkbox.className.indexOf('checked') < 0
          wskCheckboxes[i].checkbox.className += ' checked'
        else
          wskCheckboxes[i].checkbox.className = 'chk-span'
        break
    return

  findCheckBoxes = ->
    labels = document.getElementsByTagName('label')
    i = labels.length
    while i--
      posCheckbox = document.getElementById(labels[i].getAttribute('for'))
      if posCheckbox != null and posCheckbox.type == 'checkbox'
        text = labels[i].innerText
        span = document.createElement('span')
        span.className = 'chk-span'
        span.tabIndex = i
        labels[i].insertBefore span, labels[i].firstChild
        addEventHandler span, 'click', clickHandler
        addEventHandler span, 'keyup', keyHandler
        addEventHandler labels[i], 'click', clickHandlerLabel
        wskCheckboxes.push
          'checkbox': span
          'id': labels[i].getAttribute('for')
    return

  { init: findCheckBoxes }
wskCheckbox.init()
return