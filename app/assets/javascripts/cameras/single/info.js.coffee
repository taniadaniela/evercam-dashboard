previous = undefined
map_loaded = false

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
  event.preventDefault()
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
  camera_id = $(this).attr("camera_id")
  current_tab = $(this).attr("data-model")
  if current_tab is "setting"
    field  = $('#settings_new_owner_email')
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
        if current_tab is "setting"
          Notification.show data.message
        else
          setChangeOwnerDialogError(data.message)
          showChangeOwnerDialog(false)
      true
    data =
      camera_id: camera_id
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
  $("#details").on "change", "#camera-vendor", (e) ->
    e.preventDefault()
    loadVendorModels($(this).val())

loadVendorModels = (vendor_id) ->
  $("#camera-model option").remove()
  if vendor_id is ""
    return
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
      if model.name.toLowerCase().indexOf('default') isnt -1
        $("#camera-model").prepend("<option jpg-val='#{jpg_url}' value='#{model.id}' #{selected}>#{model.name}</option>")
      else
        $("#camera-model").append("<option jpg-val='#{jpg_url}' value='#{model.id}' #{selected}>#{model.name}</option>")

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    contentType: "application/json; charset=utf-8"
    type: 'GET'
    url: "#{Evercam.API_URL}models.json"

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
    url: "#{Evercam.API_URL}vendors.json"

  sendAJAXRequest(settings)
  true

saveMapLocation = ->
  data = {}
  
  locs = $("#camera_Lats_Lng").val().split(/(?:,| )+/) 
  if locs.length == 2
    ilat = parseFloat(locs[0], 10)
    ilng = parseFloat(locs[1], 10)
    
    if isNaN(ilat) || isNaN(ilng)
      $(".bb-alert").removeClass("alert-info").addClass("alert-danger")
      Notification.show "Invalid latitude or longitude value"
      return
    else
      $("#cameraLats").val(ilat)
      $("#cameraLng").val(ilng)
  
  else
    $(".bb-alert").removeClass("alert-info").addClass("alert-danger")
    Notification.show "Invalid latitude or longitude value"
    return

  $(".bb-alert").removeClass("alert-danger").addClass("alert-info")
  
  data.location_lat = $("#cameraLats").val()
  data.location_lng = $("#cameraLng").val()

  onError = (jqXHR, status, error) ->
    false

  onSuccess = (result, status, jqXHR) ->
    $("#static-map").attr('src',"https://maps.googleapis.com/maps/api/staticmap?zoom=14&size=780x350&maptype=roadmap&markers=label:C|#{$('#cameraLats').val()},%20#{$('#cameraLng').val()}")
    $("#static-map").toggle()
    $("#map-info").toggle()
    $("#search-location").toggle()
    $("#search-coordinates").toggle()
    $("#search-notes").toggle()

    $("#coordinates-value").text("#{$('#cameraLats').val()}, #{$('#cameraLng').val()}")
    Notification.show "Camera location updated successfully"
    true

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    contentType: "application/x-www-form-urlencoded"
    type: 'PATCH'
    url: "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}.json?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"

  sendAJAXRequest(settings)
  true

initializeMap = ->
  if map_loaded
    return
  map_loaded = true
  markers = []
  $("#co-ordinates").replaceWith "<p>The location is not set. Drag the marker to the location of your camera.</p>" if Evercam.Camera.location.lng  is "0"

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
    draggable: true
    title: "Camera Location"
  )
  mapFirstClick = false
  $("#maps-tab-fix").click ->
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
    setLatsLngVal(marker.getPosition().lat().toFixed(7),marker.getPosition().lng().toFixed(7))

  # Create the search box and link it to the UI element.
  search_input = document.getElementById('search-location')
  map.controls[google.maps.ControlPosition.TOP_LEFT].push search_input
  searchBox = new (google.maps.places.SearchBox)(search_input)

  # [START region_getplaces]
  # Listen for the event fired when the user selects an item from the
  # pick list. Retrieve the matching places for that item.
  google.maps.event.addListener searchBox, 'places_changed', ->
    places = searchBox.getPlaces()
    if places.length == 0
      return

    #for marker in markers
    #  marker.setMap null
    # For each place, get the icon, place name, and location.
    markers = []
    bounds = new (google.maps.LatLngBounds)
    for place in places
      # Create a marker for each place.
      marker = new (google.maps.Marker)(
        map: map
        title: place.name
        draggable: true
        position: place.geometry.location)

      markers.push marker
      setLatsLngVal(marker.getPosition().lat().toFixed(7),marker.getPosition().lng().toFixed(7))
      bounds.extend place.geometry.location

      # Register Custom "dragend" Event
      google.maps.event.addListener marker, "dragend", ->
        # Get the Current position, where the pointer was dropped
        point = marker.getPosition()
        # Center the map at given point
        map.panTo point
        # Update the textbox
        setLatsLngVal(marker.getPosition().lat().toFixed(7),marker.getPosition().lng().toFixed(7))
    map.fitBounds bounds
    map.setZoom(14)
    return
  # [END region_getplaces]
  # Bias the SearchBox results towards places that are within the bounds of the
  # current map's viewport.
  google.maps.event.addListener map, 'bounds_changed', ->
    bounds = map.getBounds()
    searchBox.setBounds bounds
    return

  setLatsLngVal = (lat, lng) ->
    document.getElementById("camera_Lats_Lng").value = "#{lat}, #{lng}"
    $(cameraLats).val lat
    $(cameraLng).val lng

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

handleMapEvents = ->
  $('#search-location').keydown (event) ->
    if event.which == 13
      event.preventDefault()
  unless Evercam.Camera.location.lng is "0"
    $(".edit-location").click ->
      $("#static-map").toggle()
      $("#map-info").toggle()
      #$("#save-map-location").click ->
      $("#search-location").toggle()
      $("#search-coordinates").toggle()
      $("#search-notes").toggle()

window.initializeInfoTab = ->
  $('.open-sharing').click(showSharingTab)
  $('#change_owner_button').click(onChangeOwnerButtonClicked)
  $('.change_camera_ownership').click(onChangeOwnerSubmitClicked)

  if Evercam.Camera.location.lng is ""
    $("#info-location").replaceWith "<p>Not set</p>"
  $.validate()
  handleVendorModelEvents()
  google.maps.event.addDomListener document.getElementById("edit-location"), "click", initializeMap
  handleModelEvents()
  initNotification()
  $("#save-map-location").on "click", saveMapLocation
  handleMapEvents()
