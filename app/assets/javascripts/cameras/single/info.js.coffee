previous = undefined

sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = jQuery.ajax(settings)
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
  $("#camera-vendor").on "change", ->
    loadVendorModels($(this).val())

  $(".camera-model").on "change", ->
    $("#snapshot").val $(this).find(":selected").attr("jpg-val")
  true

loadVendorModels = (vendor_id) ->
  $("#camera-model option").remove()
  $("#camera-model").append('<option value="">Loading...</option>');
  data = {}
  data.vendor_id = vendor_id
  data.limit = 400
  data.api_id = Evercam.User.api_id
  data.api_key = Evercam.User.api_key

  onError = (jqXHR, status, error) ->
    false

  onSuccess = (result, status, jqXHR) ->
    $("#camera-model option").remove()
    if result.models.length == 0
      $("#camera-model").append('<option value="">No Model Found</option>');
      return

    models = sortByKey(result.models, "name")
    for model in models
      selected = if model.name == Evercam.Camera.model_name then 'selected="selected"' else ''
      jpg_url = if model.defaults.snapshots then model.defaults.snapshots.jpg else ''
      $("#camera-model").append("<option jpg-val='#{jpg_url}' value='#{model.id}' #{selected}>#{model.name}</option>")
    $("#snapshot").val $("#camera-model").find(":selected").attr("jpg-val")

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    contentType: "application/json; charset=utf-8"
    type: 'GET'
    url: "#{Evercam.API_URL}models/search.json"

  sendAJAXRequest(settings)
  true

sortByKey = (array, key) ->
  array.sort (a, b) ->
    x = a[key]
    y = b[key]
    (if (x < y) then -1 else ((if (x > y) then 1 else 0)))

loadVendors = ->
  data = {}
  data.api_id = Evercam.User.api_id
  data.api_key = Evercam.User.api_key

  onError = (jqXHR, status, error) ->
    false

  onSuccess = (result, status, jqXHR) ->
    vendors = sortByKey(result.vendors, "name")
    for vendor in vendors
      selected = ''
      if vendor.id == Evercam.Camera.vendor_id
        selected = 'selected="selected"'
        loadVendorModels(vendor.id)
      $("#camera-vendor").append("<option value='#{vendor.id}' #{selected}>#{vendor.name}</option>")

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    contentType: "application/json; charset=utf-8"
    type: 'GET'
    url: "#{Evercam.API_URL}vendors/search.json"

  sendAJAXRequest(settings)
  true

initializeMap = ->
  $("#co-ordinates").replaceWith "<p>The location is not set. Drag the marker to the location of your camera.</p>" if Evercam.Camera.location.lng  is "0"
  unless Evercam.Camera.location.lng is "0"
    $(".edit-location").click ->
      $("#testies").toggle()

  cameraLatlng = new google.maps.LatLng(Evercam.Camera.location.lat, Evercam.Camera.location.lng)
  if Evercam.Camera.location.lng is "0"
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
    $(this).closest("form")[0].reset()

centerModal = ->
  if $("#camera-vendor option").length == 1
    loadVendors()
  $(this).css "display", "block"
  $dialog = $(this).find(".modal-dialog")
  offset = ($(window).height() - $dialog.height()) / 2

  # Center modal vertically in window
  $dialog.css "margin-top", offset

initNotification = ->
  Notification.init(".bb-alert");
  if notifyMessage
    Notification.show notifyMessage

window.initializeInfoTab = ->
  $('.open-sharing').click(showSharingTab)
  $('#change_owner_button').click(onChangeOwnerButtonClicked)
  $('#submit_change_owner_button').click(onChangeOwnerSubmitClicked)

  if Evercam.Camera.location.lng is ""
    $("#info-location").replaceWith "<p>Not set</p>"
  $.validate()
  handleVendorModelEvents()
  google.maps.event.addDomListener window, "load", initializeMap
  handleModelEvents()
  initNotification()
  true
