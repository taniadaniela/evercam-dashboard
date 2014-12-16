showFeedback = (message) ->
  Notification.show(message)
  true

onLoadingError = ->
  $('img.live').on 'error', () ->
    showFeedback("Error loading camera image. Camera might be offline.")
  true

refreshImages = ->
  $('img.snap').each ->
    oldimg = $(this)
    $("<img class='snap' />").attr({"data-proxy": $(this).attr('data-proxy'), "src": $(this).attr('data-proxy') + '&' + new Date().getTime()}).load () ->
      if not this.complete or this.naturalWidth is undefined or this.naturalWidth is 0
        showFeedback('Error loading camera image. Camera might be offline.')
      else
        oldimg.replaceWith($(this))

onRefreshImage = ->
  $(".refresh-images").on 'click', () ->
    refreshImages()
  true

disableOther = (button) ->
  classie.toggle showLeft, "disabled"  if button isnt "showLeft"
  return

showHideLeftNav = ->
  menuLeft = document.getElementById("cbp-spmenu-s1")
  showLeft = document.getElementById("showLeft")
  body = document.body
  showLeft.onclick = ->
    classie.toggle this, "active"
    classie.toggle menuLeft, "cbp-spmenu-open"
    disableOther "showLeft"
  true

initNotification = ->
  Notification.init(".bb-alert");
  if notifyMessage
    Notification.show notifyMessage

initializeCameras = ->
  Metronic.init()
  Layout.init()
  QuickSidebar.init()
  initNotification()
  onLoadingError()
  refreshImages()
  showHideLeftNav()
  onRefreshImage()
  true

if !window.Evercam
  window.Evercam = {}

window.Evercam.Cameras =
  initializeCameras: initializeCameras