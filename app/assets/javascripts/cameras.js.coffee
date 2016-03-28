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

hideThumbnailGif = ->
  $('.refresh-camera-thumbnail').on "click", ->
    gifid = $(this)
    camera_id = gifid.attr 'id'
    camera_tid = '#' + camera_id
    $("#{camera_tid} i").hide()
    $("#{camera_tid} img").show()
    refreshCameraStatus(camera_id, camera_tid)

hidegif = (camera_tid) ->
  $("#{camera_tid} i").show()
  $("#{camera_tid} img").hide()

refreshCameraStatus = (id, tid) ->
  data = {}
  data.with_data = true

  gif_id = id
  gif_tid = tid

  onError = (jqXHR, status, error) ->
    hidegif(gif_tid)

  onSuccess = (data, status, jqXHR) ->
    hidegif(gif_tid)

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    contentType: "application/x-www-form-urlencoded"
    type: 'POST'
    url: "#{Evercam.API_URL}cameras/#{gif_id}/recordings/snapshots?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"

  sendAJAXRequest(settings)

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
  hideThumbnailGif()
  $('[data-toggle="tooltip"]').tooltip()
