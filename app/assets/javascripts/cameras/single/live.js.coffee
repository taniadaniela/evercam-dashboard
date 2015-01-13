default_img = "/assets/offline.svg"
int_time = undefined
refresh_paused = false
image_placeholder = undefined

loadImage = ->
  img = new Image()
  live_snapshot_url = "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/snapshot.jpg?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"
  src = "#{$("#live-snapshot-url").val()}&rand=" + new Date().getTime()
  img.onload = ->
    unless not image_placeholder.parent
      image_placeholder.parent.replaceChild img, image_placeholder
    else
      image_placeholder.src = src
    $(".btn-live-player").removeClass "hide"
  img.src = src

toggleRefresh = (hash) ->
  if window.Evercam.Camera.is_online
    if not refresh_paused and hash is "#live"
      int_time = setInterval(loadImage, 1000)
    else
      clearInterval int_time

controlButtonEvents = ->
  $(".play-pause").on "click", ->
    if refresh_paused
      int_time = setInterval(loadImage, 1000)
      refresh_paused = false
      $(this).children().removeClass "icon-control-play"
      $(this).children().addClass "icon-control-pause"
    else
      clearInterval int_time
      refresh_paused = true
      $(this).children().removeClass "icon-control-pause"
      $(this).children().addClass "icon-control-play"
  $(".refresh-live-snap, .refresh-camera").on "click", ->
    loadImage()

fullscreenImage = ->
  $("#toggle").click ->
    screenfull.toggle $("#live-player-image")[0]

  if screenfull.enabled
    document.addEventListener screenfull.raw.fullscreenchange, ->
      if screenfull.isFullscreen
        $("#live-player-image").css('width','auto')
      else
        $("#live-player-image").css('width','100%')

window.initializeLiveTab = ->
  image_placeholder = document.getElementById("live-player-image")
  controlButtonEvents()
  fullscreenImage()
  toggleRefresh(window.location.hash)
  $('a[data-toggle="tab"]').on "click", ->
    hash = this.href.substr(this.href.indexOf("#"));
    toggleRefresh(hash)
