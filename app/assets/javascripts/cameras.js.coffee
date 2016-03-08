window.showFeedback = (message) ->
  Notification.show(message)
  true

refreshthumbs = ->
  images = $('.snapshot img')
  for img in images
    img_id = img.alt
    img_url = "#{Evercam.API_URL}cameras/#{img_id}/live/snapshot.jpg?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"
    src = "#{img_url}&rand=" + new Date().getTime()
    img.src = src
    img.onerror ->
      img.src = "#{Evercam.API_URL}cameras/#{img_id}/thumbnail?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"
  setInterval refreshthumbs, 60000

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
  refreshthumbs()
  $('[data-toggle="tooltip"]').tooltip()
