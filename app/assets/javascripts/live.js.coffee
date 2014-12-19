default_img = "/assets/offline.svg"
int_time = undefined
is_pause = false
image_placeholder = undefined

loadImage = ->
  img = new Image()
  src = "#{$("#live-snapshot-url").val()}&rand=" + new Date().getTime()
  img.onload = ->
    unless not image_placeholder.parent
      image_placeholder.parent.replaceChild img, image_placeholder
    else
      image_placeholder.src = src
    $(".btn-live-player").removeClass "hide"
  img.src = src
  return

handleTabEvent = ->
  $('a[data-toggle="tab"]').on "click", ->
    if window.Evercam.cameraIsOnline
      tabName = $(this).html()
      if not is_pause and tabName is "Live View"
        int_time = setInterval(loadImage, 1000)
      else
        clearInterval int_time

controlButtonEvents = ->
  $(".play-pause").on "click", ->
    if is_pause
      int_time = setInterval(loadImage, 1000)
      is_pause = false
      $(this).children().removeClass "icon-control-play"
      $(this).children().addClass "icon-control-pause"
    else
      clearInterval int_time
      is_pause = true
      $(this).children().removeClass "icon-control-pause"
      $(this).children().addClass "icon-control-play"
  $(".refresh-live-snap, .refresh-camera").on "click", ->
    loadImage()
  true

fullscreenImage = ->
  $("#toggle").click ->
    screenfull.toggle $("#live-player-image")[0]

  if screenfull.enabled
    document.addEventListener screenfull.raw.fullscreenchange, ->
      if screenfull.isFullscreen
        $("#live-player-image").css('width','auto');
      else
        $("#live-player-image").css('width','100%');
  return


validateImage = (image) ->
  img = new Image()
  img.onerror = ->
    image.src = default_img
    if image.id is "live-player-image"
      $(".btn-live-player").addClass "hide"
      $(".refresh-live-snap").removeClass "hide"
  img.src = image.src
  return

initializeLiveTab = ->
  image_placeholder = document.getElementById("live-player-image")

  handleTabEvent()
  controlButtonEvents()
  fullscreenImage()
  validateImage image for image in document.getElementsByTagName("IMG")
  true

if !window.Evercam
  window.Evercam = {}

window.Evercam.Live =
  initializeTab: initializeLiveTab
