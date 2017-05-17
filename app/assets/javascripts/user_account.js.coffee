handleEditable = ->
  $('.makeNonEditable').on 'click', ->
    $('#userProfile input:text').attr 'readonly', 'readonly'
    $('select').attr 'disabled', 'disabled'
    return
  $('.makeEditable').on 'click', ->
    $('#userProfile input:text').removeAttr 'readonly'
    $('select').removeAttr 'disabled'
    return

showHideMessage = ->
  $('#hide').click ->
    $('.hide-p').fadeOut()

  $('#hide-2').click ->
    $('.hide-p').fadeOut()

  $('#show').click ->
    $('.hide-p').fadeIn()


handlePasswordChange = ->
  $('#change-password').on 'click', ->
    NProgress.start()
    if $('#new-password').val() != $('#password_again').val()
      $('#wrong-confirm-password').show()
      $('#password_again').addClass 'border-red'
      NProgress.done()
      return false
    $('#wrong-confirm-password').hide()
    NProgress.done()
    $('#password_again').removeClass 'border-red'
    true

initializeiCheck = ->
  $("input[type=radio], input[type=checkbox]").iCheck
    checkboxClass: "icheckbox_flat-blue"
    radioClass: "iradio_flat-blue"

onDeleteClick = ->
  $("#close-account").on 'click', ->
    is_checked = true
    $(".camera-delete").each ->
      if !$(this).is(":checked")
        is_checked = false
        return
    if !is_checked
      $(".bb-alert").removeClass("alert-info").addClass("alert-danger")
      Notification.show "Please tick the box(es) to confirm you would like to delete each of your cameras"
      return false
    if $("#delete-camera").val().toLowerCase() isnt 'delete'
      $(".bb-alert").removeClass("alert-info").addClass("alert-danger")
      Notification.show "Please type 'Delete' to confirm delete your account"
      return false
    return true

saveUserSettings = ->
  if $.cookie("hide-offline-cameras")
    $("#hide-offline-cameras").prop("checked", true)
  $("#hide-offline-cameras").on "click", ->
    hide_cameras = $(this).prop("checked")
    if hide_cameras
      $.cookie("hide-offline-cameras", $(this).prop("checked"), { expires: 365, path: "/" })
    else
      $.removeCookie("hide-offline-cameras", { path: "/" })

window.initializeUserAccount = ->
  $.validate()
  Metronic.init()
  Layout.init()
  QuickSidebar.init()
  Notification.init(".bb-alert")
  handleEditable()
  showHideMessage()
  handlePasswordChange()
  saveUserSettings()
  onDeleteClick()
  NProgress.done()

initialize = ->
  markers = []
  map = new (google.maps.Map)(document.getElementById('map-canvas'), mapTypeId: google.maps.MapTypeId.ROADMAP)
  defaultBounds = new (google.maps.LatLngBounds)(new (google.maps.LatLng)(-33.8902, 151.1759), new (google.maps.LatLng)(-33.8474, 151.2631))
  map.fitBounds defaultBounds
  # Create the search box and link it to the UI element.
  input = document.getElementById('pac-input')
  map.controls[google.maps.ControlPosition.TOP_LEFT].push input
  searchBox = new (google.maps.places.SearchBox)(input)
  # Listen for the event fired when the user selects an item from the
  # pick list. Retrieve the matching places for that item.
  google.maps.event.addListener searchBox, 'places_changed', ->
    `var marker`
    `var i`
    places = searchBox.getPlaces()
    if places.length == 0
      return
    i = 0
    marker = undefined
    while marker = markers[i]
      marker.setMap null
      i++
    # For each place, get the icon, place name, and location.
    markers = []
    bounds = new (google.maps.LatLngBounds)
    i = 0
    place = undefined
    while place = places[i]
      image =
        url: place.icon
        size: new (google.maps.Size)(71, 71)
        origin: new (google.maps.Point)(0, 0)
        anchor: new (google.maps.Point)(17, 34)
        scaledSize: new (google.maps.Size)(25, 25)
      # Create a marker for each place.
      marker = new (google.maps.Marker)(
        map: map
        icon: image
        title: place.name
        position: place.geometry.location)
      markers.push marker
      bounds.extend place.geometry.location
      i++
    map.fitBounds bounds
    return
  # Bias the SearchBox results towards places that are within the bounds of the
  # current map's viewport.
  google.maps.event.addListener map, 'bounds_changed', ->
    bounds = map.getBounds()
    searchBox.setBounds bounds
    return
  return
