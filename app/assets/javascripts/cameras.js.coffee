window.showFeedback = (message) ->
  Notification.show(message)

refreshThumbnails = ->
  $('.camera-thumbnail').each ->
    img = $(this)
    img_url = img.attr "data-proxy"
    if img_url.endsWith "thumbnail"
      src = "#{img_url}?rand=" + new Date().getTime()
    else
      src = "#{img_url}&rand=" + new Date().getTime()
    img.attr "src", src
  setTimeout refreshThumbnails, 60000

initNotification = ->
  Notification.init(".bb-alert");
  if notifyMessage
    Notification.show notifyMessage

window.initializeCameraIndex = ->
  Metronic.init()
  Layout.init()
  QuickSidebar.init()
  initNotification()
  refreshThumbnails()
  $('[data-toggle="tooltip"]').tooltip()
