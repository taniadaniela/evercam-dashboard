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

switchToTab = ->
  tab = window.Evercam.request.subpath.split('/')[0]
  $(".nav-tab-#{tab}").tab('show')

handleTabClick = ->
  $('.nav-tabs a').on 'click', ->
    clicked_path = $(this).attr('data-target').replace('#', '')
    window.history.pushState( {} , "#{clicked_path}", "#{window.Evercam.request.rootpath}/#{clicked_path}" );

handleBackForwardButton = ->
  window.addEventListener 'popstate', (e) ->
    tab = document.location.pathname
      .replace(window.Evercam.request.rootpath, '')
      .replace('/', '')
    $(".nav-tab-#{tab}").tab('show')

initializeTabs = ->
  window.initializeInfoTab()
  window.initializeLiveTab()
  window.initializeRecordingsTab()
  window.initializeLogsTab()
  window.initializeSharingTab()
  window.initializeWebhookTab()
  window.initializeExplorerTab()

window.initializeCameraSingle = ->
  switchToTab()
  handleTabClick()
  handleBackForwardButton()
  Metronic.init()
  Layout.init()
  QuickSidebar.init()
  initializeTabs()
  initializeiCheck()
  initializeDropdowns()
  handleCameraDelete()
