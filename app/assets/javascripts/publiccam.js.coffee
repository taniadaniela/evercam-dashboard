showError = (message) ->
  Notification.show(message)
  true

showFeedback = (message) ->
  Notification.show(message)
  true

onAddShareClicked = (event) ->
  event.preventDefault()
  link=$(event.target)
  emailAddress = link.attr("email")
  cameraID = link.attr("camera_id")
  permissions = "minimal"
  onError = (jqXHR, status, error) ->
    showError("Add camera to my shared cameras failed.")
    false
  onSuccess = (data, status, jqXHR) ->
    if data.success
      showFeedback("Successfully added to your shared cameras.")
    else
      showError("Camera has already been added to your shared cameras.")
    true
  window.Evercam.Share.createShare(cameraID, emailAddress, permissions, onSuccess, onError)
  true

setList = ->
  $.removeCookie('public-style')
  $.cookie('public-style', 'list', { expires: 365 })

setGrid = ->
  $.removeCookie('public-style')
  $.cookie('public-style', 'grid', { expires: 365 })

initialize = ->
  $(".create-share-button").click(onAddShareClicked)
  $('#grid-style').click(setGrid)
  $('#list-style').click(setList)
  Notification.init(".bb-alert")
  true

if !window.Evercam
  window.Evercam = {}

window.Evercam.Publiccam =
  initialize: initialize



