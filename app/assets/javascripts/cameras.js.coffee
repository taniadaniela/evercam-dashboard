window.showFeedback = (message) ->
  Notification.show(message)
  true

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

handlePusherEventIndex = ->
  channel = Evercam.Pusher.subscribe(Evercam.User.username)
  channel.bind 'user_cameras_changed', (data) ->
    $('#camera-index.page-content').load "#{Evercam.request.rootpath} #camera-index.page-content > *", ->
      window.refreshThumbnails()

initNotification = ->
  Notification.init(".bb-alert");
  if notifyMessage
    Notification.show notifyMessage

window.initializeCameraIndex = ->
  Metronic.init()
  Layout.init()
  QuickSidebar.init()
  initNotification()
  handlePusherEventIndex()
  setTimeout refreshThumbnails, 60000
  $('[data-toggle="tooltip"]').tooltip()
