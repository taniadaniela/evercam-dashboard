#= require evercam.js.coffee
#= require cameras/single/info.js.coffee
#= require cameras/single/live.js.coffee
#= require cameras/single/sharing.js.coffee
#= require cameras/single/snapshots_navigator.js.coffee
#= require cameras/single/api_explorer.js.coffee
#= require cameras/single/logs.js.coffee
#= require cameras/single/webhooks.js.coffee
#= require cameras/single/testsnapshot.js.coffee

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

cameraDeleteConfirm = ->
  $("#delete-camera").on "click", ->
    if $("#camera_specified_id") && $("#camera_specified_id").val() is ''
      $("#delete-camera-error").text("Please enter camera id to confirm delete camera.")
      $("#delete-camera-error").show()
      setTimeout (->
        $("#delete-camera-error").hide()
      ), 6000
      return false
    return true

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
  cameraDeleteConfirm()
