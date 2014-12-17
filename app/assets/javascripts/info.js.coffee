previous = undefined

onSetCameraAccessClicked = (event) ->
	true

showSharingTab = ->
  $('.nav-tabs a[href=#sharing]').tab('show');
  setTimeout(->
    scrollTo(0, 0)
  10);

onChangeOwnerButtonClicked = (event) ->
   event .preventDefault()
   showChangeOwnerDialog(true)
   true

setChangeOwnerDialogError = (message) ->
   $('#change_owner_error').text(message)
   if message == ''
      $('#change_owner_error').hide()
   else
      $('#change_owner_error').show()
   true

onChangeOwnerSubmitClicked = (event) ->
   event.preventDefault()
   field  = $('#new_owner_email')
   if field.val() != ''
      dialog = $('#change_owner_dialog')
      dialog.modal('hide')
      setChangeOwnerDialogError("")
      onError = (jqXHR, status, error) ->
         setChangeOwnerDialogError("An error occurred transferring ownership of this camera. Please try again and, if the problem persists, contact support.")
         showChangeOwnerDialog(false)
         true
      onSuccess = (data, status, jqXHR) ->
         if data.success
            alert("Camera ownership has been successfully transferred.")
            location = window.location
            location.assign(location.protocol + "//" + location.host)
         else
            setChangeOwnerDialogError(data.message)
            showChangeOwnerDialog(false)            
         true
      data =
         camera_id: $('#change_owner_camera_id').val()
         email: field.val()
      settings =
         cache: false
         data: data
         error: onError
         success: onSuccess
         url: '/cameras/transfer'
      jQuery.ajax(settings)
   true

showChangeOwnerDialog = (clear) ->
   if clear
      $('#new_owner_email').val("")
      $('#change_owner_error').hide()
   $('#change_owner_dialog').modal('show')
   onComplete = ->
      $('#new_owner_email').select();
   setTimeout(onComplete, 200);
   true

handleVendorModelEvents = ->
  $("#camera-vendor").one("focus", ->
    previous = @value
  ).on "change", ->
    $("#camera-model" + previous).addClass "hidden"
    $("#camera-model" + @value).removeClass "hidden"
    $("#snapshot").val $("#camera-model" + @value).find(":selected").attr("jpg-val")
    previous = @value

  $(".camera-model").on "change", ->
    $("#snapshot").val $(this).find(":selected").attr("jpg-val")
  true

initializeMap = ->
  $("#co-ordinates").replaceWith "<p>The location is not set. Drag the marker to the location of your camera.</p>"  if cameraLong is "0"
  unless cameraLong is "0"
    $(".edit-location").click ->
      $("#testies").toggle()

  cameraLatlng = new google.maps.LatLng(cameraLat, cameraLong)
  if cameraLong is "0"
    mapOptions =
      zoom: 0
      minZoom: 2
      maxZoom: 17
      center: cameraLatlng
  else
    mapOptions =
      zoom: 14
      minZoom: 2
      maxZoom: 17
      center: cameraLatlng
  map = new google.maps.Map(document.getElementById("map-info"), mapOptions)
  marker = new google.maps.Marker(
    position: cameraLatlng
    map: map
    draggable: false
    title: "Camera Location"
  )
  mapFirstClick = false
  $("#nav-tabs-2").click ->
    mapFirstClick or setTimeout(->
      google.maps.event.trigger map, "resize"
      mapFirstClick = true
      map.setCenter cameraLatlng
      return
    , 200)

  # Register Custom "dragend" Event
  google.maps.event.addListener marker, "dragend", ->
    $("#location-settings").css "display", "block"

  # Register Custom "dragend" Event
  google.maps.event.addListener marker, "dragend", ->

    # Get the Current position, where the pointer was dropped
    point = marker.getPosition()

    # Center the map at given point
    map.panTo point

    # Update the textbox
    document.getElementById("cameraLats").value = point.lat()
    document.getElementById("cameraLng").value = point.lng()
    $(cameraLats).val marker.getPosition().lat().toFixed(7)
    $(cameraLng).val marker.getPosition().lng().toFixed(7)

  return

handleModelEvents = ->
  $(".modal").on "show.bs.modal", centerModal
  $(window).on "resize", ->
    $(".modal:visible").each centerModal

  $(".modal").on "hidden.bs.modal", ->
    $(this).find("form")[0].reset()

centerModal = ->
  $(this).css "display", "block"
  $dialog = $(this).find(".modal-dialog")
  offset = ($(window).height() - $dialog.height()) / 2

  # Center modal vertically in window
  $dialog.css "margin-top", offset

initNotification = ->
  Notification.init(".bb-alert");
  if notifyMessage
    Notification.show notifyMessage

initializeInfoTab = ->
  $('#set_permissions_submit').click(onSetCameraAccessClicked)
  $('.open-sharing').click(showSharingTab)
  $('#change_owner_button').click(onChangeOwnerButtonClicked)
  $('#submit_change_owner_button').click(onChangeOwnerSubmitClicked)

  if cameraLong is ""
    $("#info-location").replaceWith "<p>Not set</p>"
  $.validate()
  handleVendorModelEvents()
  google.maps.event.addDomListener window, "load", initializeMap
  handleModelEvents()
  initNotification()
  true

if !window.Evercam
   window.Evercam = {}

window.Evercam.Info =
   initializeTab: initializeInfoTab

