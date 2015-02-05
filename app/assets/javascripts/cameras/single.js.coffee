#= require evercam.js.coffee
#= require cameras/single/info.js.coffee
#= require cameras/single/live.js.coffee
#= require cameras/single/sharing.js.coffee
#= require cameras/single/snapshots_navigator.js.coffee
#= require cameras/single/api_explorer.js.coffee
#= require cameras/single/logs.js.coffee
#= require cameras/single/webhooks.js.coffee
#= require cameras/single/testsnapshot.js.coffee

sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = jQuery.ajax(settings)
  true

handleScrollToEvents = ->
  # Javascript to enable link to tab
  url = document.location.toString()
  if url.match("#")
    $(".nav-tabs a[href=#" + url.split("#")[1] + "]").tab "show"
    setTimeout (->
      scrollTo 0, 0
      return
    ), 10
  $(".nav-tabs").tabdrop "layout"

  # Change hash for page-reload
  $(".nav-tabs a").on "shown.bs.tab", (e) ->
    window.location.hash = e.target.hash
    scrollTo 0, 0

initializeiCheck = ->
  $("input[type=radio], input[type=checkbox]").iCheck
    checkboxClass: "icheckbox_flat-blue"
    radioClass: "iradio_flat-blue"

initializeDropdowns = ->
  $("[data-toggle=\"tooltip\"]").tooltip()
  $(".dropdown-toggle").dropdown()

onCameraDeleteError = (jqXHR, status, error) ->
  Notification.show "An error occurred removing your camera. Please try again and, if the problem persists, contact support."
  true

onCameraDeleteSuccess = (data, status, jqXHR) ->
  if data.success
    Notification.show "Camera deleted successfully."
    window.location = '/'
  else
    Notification.show data.message
  true

handleCameraDelete = ->
  $("#delete-camera").on "click", ->
    if $("#camera_specified_id") && $("#camera_specified_id").val() is ''
      Notification.show "Please enter camera id to confirm delete camera."
      return

    data =
      share: $("#share").val()
      camera_specified_id: $("#camera_specified_id").val()

    settings =
      cache: false
      data: data
      error: onCameraDeleteError
      success: onCameraDeleteSuccess
      url: "/cameras/#{$("#id").val()}"
      type: 'DELETE'
    jQuery.ajax(settings)

  $("#remove-camera").on "click", ->
    data =
      share: $("#share").val()
      share_id: $("#share_id").val()

    settings =
      cache: false
      data: data
      error: onCameraDeleteError
      success: onCameraDeleteSuccess
      url: "/cameras/#{$("#id").val()}"
      type: 'DELETE'
    jQuery.ajax(settings)


initializeTabs = ->
  window.initializeInfoTab()
  window.initializeLiveTab()
  window.initializeRecordingsTab()
  window.initializeLogsTab()
  window.initializeSharingTab()
  window.initializeWebhookTab()
  window.initializeExplorerTab()

window.initializeCameraSingle = ->
  Metronic.init()
  Layout.init()
  QuickSidebar.init()
  handleScrollToEvents()
  initializeTabs()
  initializeiCheck()
  initializeDropdowns()
  handleCameraDelete()
