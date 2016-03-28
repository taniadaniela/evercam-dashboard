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
    id = gifid.attr 'id'
    tid = '#' + id
    $("#{tid} i").hide()
    $("#{tid} img").show()
    refreshCameraStatus(id, tid)

hidegif = (tid) ->
  $("#{tid} i").show()
  $("#{tid} img").hide()

refreshCameraStatus = (id, tid) ->
  data = {}
  data.with_data = true

  gifid = id
  giftid = tid

  onError = (jqXHR, status, error) ->
    hidegif(giftid)

  onSuccess = (data, status, jqXHR) ->
    hidegif(giftid)

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    contentType: "application/x-www-form-urlencoded"
    type: 'POST'
    url: "#{Evercam.API_URL}cameras/#{gifid}/recordings/snapshots?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"

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
