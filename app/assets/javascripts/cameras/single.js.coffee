#= require evercam.js.coffee
#= require cameras/single/info.js.coffee
#= require cameras/single/live.js.coffee
#= require cameras/single/sharing.js.coffee
#= require cameras/single/snapshots_navigator.js.coffee
#= require cameras/single/api_explorer.js.coffee
#= require cameras/single/logs.js.coffee
#= require cameras/single/local_storage.js.coffee
#= require cameras/single/settings.js.coffee
#= require cameras/single/testsnapshot.js.coffee
#= require cameras/single/archives.js.coffee
#= require saveimage.js
#= require proxy.js

window.sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = $.ajax(settings)

initializeiCheck = ->
  $("input[type=radio], input[type=checkbox]").iCheck
    checkboxClass: "icheckbox_flat-blue"
    radioClass: "iradio_flat-blue"

initializeDropdowns = ->
  $("[data-toggle=\"tooltip\"]").tooltip()
  $(".dropdown-toggle").dropdown()

switchToTab = ->
  $(".nav-tab-#{Evercam.request.tabpath}").tab('show')

handleTabClick = ->
  $('.nav-tabs a').on 'click', ->
    clicked_path = $(this).attr('data-target').replace('#', '')
    if window.history and window.history.pushState
      window.history.pushState( {} , "#{clicked_path}", "#{window.Evercam.request.rootpath}/#{clicked_path}" );
  $(".nav-tabs").tabdrop "layout"

handleBackForwardButton = ->
  window.addEventListener 'popstate', (e) ->
    tab = document.location.pathname
      .replace(window.Evercam.request.rootpath, '')
      .split('/')[1]
    $(".nav-tab-#{tab}").tab('show')

handlePusherEventSingle = ->
  channel = Evercam.Pusher.subscribe(Evercam.Camera.id)
  channel.bind 'camera_changed', (data) ->
    updateCameraSinglePage()

updateCameraSinglePage = ->
  $.ajax(Evercam.request.rootpath).done (data) ->
    elements = [
      '.camera-switch'
      '#details .info-preview'
      '#camera-details-panel'
      '#camera-connection-panel'
      '#general-info-panel'
      '#urls-panel'
      '#settings-modal .modal-body'
    ]
    updateElement(data, elem) for elem in elements
    updateLiveViewPanel()

updateElement = (page, elem)->
  $(elem).html $(page).find("#{elem} > *")

updateLiveViewPanel = ->
  status = $("#camera-details-panel td > .status").text().toLowerCase()
  switch status
    when "online"
      $(".camera-preview-online").removeClass('hide')
      $(".camera-preview-offline").addClass('hide')
    when "offline"
      $(".camera-preview-online").addClass('hide')
      $(".camera-preview-offline").removeClass('hide')

handleCameraModalSubmit = ->
  $('#settings-modal').on 'click', '#add-button', ->
    $('#settings-modal').modal('hide')

handlePageLoad = ->
  setTimeout (->
    updateCameraSinglePage()
    $('.sidebar-cameras-list').load '/v1/cameras/new .sidebar-cameras-list > *', ->
      hideOfflineCameras()
  ), 2000

hideOfflineCameras = ->
  total_offline_cameras = $(".sidebar-cameras-list li.sidebar-offline").length
  $("#total-offline-cameras").attr("data-original-title", "#{total_offline_cameras} Offline cameras")
  $("#total-offline-cameras sub").text(total_offline_cameras)
  if $.cookie("hide-offline-cameras")
    if total_offline_cameras is 0
      $("#total-offline-cameras").removeClass("hide").addClass("hide")
    else
      $("#total-offline-cameras").removeClass("hide")
    $(".sidebar-cameras-list li.sidebar-offline").removeClass("hide").addClass("hide")
  else
    $("#total-offline-cameras").removeClass("hide").addClass("hide")
    $(".sidebar-cameras-list li.sidebar-offline").removeClass("hide")

addToMyCameras = ->
  $('#add-to-cameras').on 'click', ->
    data =
      camera_id: Evercam.Camera.id
      email: Evercam.User.username
      permissions: "minimal"

    onError = (jqXHR, status, error) ->
      Notification.show("Failed to add camera.")
      false
    onSuccess = (data, status, jqXHR) ->
      if data.success
        Notification.show("Camera successfully added.")
        window.location = "/v1/cameras/#{Evercam.Camera.id}"
      else
        message = "Adding a camera share failed."
        switch data.code
          when "camera_not_found_error"
            message = "Unable to locate details for the camera in the system. Please refresh your view and try again."
          when "duplicate_share_error"
            message = "The camera has already been shared with the specified user."
          when "duplicate_share_request_error"
            message = "A share request for that email address already exists for this camera."
          when "share_grantor_not_found_error"
            message = "Unable to locate details for the user granting the share in the system."
          when "invalid_parameters"
            message = "Invalid rights specified for share creation request."
          else
            message = data.message
        Notification.show(message)
      true

    settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      type: 'POST'
      url: '/share'
    sendAJAXRequest(settings)

initializeTabs = ->
  window.initializeInfoTab()
  window.initializeLiveTab()
  window.initializeRecordingsTab()
  window.initializeLogsTab()
  window.initializeSharingTab()
  window.initializeExplorerTab()
  window.initializeLocalStorageTab()
  window.initializeSettingsTab()
  window.initializeArchivesTab()

window.initializeCameraSingle = ->
  initializeTabs()
  handleTabClick()
  switchToTab()
  handleBackForwardButton()
  handlePusherEventSingle()
  # temporarily disabled
  #handleCameraModalSubmit()
  # temporarily added
  handlePageLoad()
  initializeiCheck()
  initializeDropdowns()
  addToMyCameras()
  $('[data-toggle="tooltip"]').tooltip()
  Metronic.init()
  Layout.init()
  QuickSidebar.init()
  SaveImage.init()
