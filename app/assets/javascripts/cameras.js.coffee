window.showFeedback = (message) ->
  Notification.show(message)
  true

refreshThumbnails = ->
  images = $('.camera-thumbnail')
  for img in images
    img_url = img.src
    src = "#{img_url}&rand=" + new Date().getTime()
    img.src = src
  setInterval refreshThumbnails, 60000

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
  refreshThumbnails()
  $('[data-toggle="tooltip"]').tooltip()
