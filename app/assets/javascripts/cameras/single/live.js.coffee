default_img = "/assets/offline.svg"
int_time = undefined
refresh_paused = false
image_placeholder = undefined

sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = $.ajax(settings)

loadImage = ->
  unless window.snapshot_streaming_enabled
    img = new Image()
    live_snapshot_url = "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/live/snapshot.jpg?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"
    src = "#{live_snapshot_url}&rand=" + new Date().getTime()
    # NOTE: temporarily commented out to disable image replacement.
    # Now image requests are only used as a trigger for websockets stream
    # See proxy.es6 for more details.
    #
    # img.onload = ->
    #   unless not image_placeholder.parent
    #     image_placeholder.parent.replaceChild img, image_placeholder
    #   else
    #     image_placeholder.src = src
    #   $(".btn-live-player").removeClass "hide"
    img.src = src

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
  $("#live-player-image").dblclick ->
    screenfull.toggle $(this)[0]

  if screenfull.enabled
    document.addEventListener screenfull.raw.fullscreenchange, ->
      if screenfull.isFullscreen
        $("#live-player-image").css('width','auto')
      else
        $("#live-player-image").css('width','100%')

openPopout = ->
  $("#link-popout").on "click", ->
    $("<img/>").attr("src", image_placeholder.src).load( ->
      window.open("/live/#{Evercam.Camera.id}", "_blank", "width=#{@width}, height=#{@height}, scrollbars=0")
    ).error ->
      window.open("/live/#{Evercam.Camera.id}", "_blank", "width=640, height=480, scrollbars=0")

initializePlayer = ->
  window.vjs_player = videojs 'camera-video-player', {techOrder: ["flash", "hls", "html5"]}

destroyPlayer = ->
  unless $('#camera-video-stream').html() == ''
    window.vjs_player.dispose()
    $("#camera-video-stream").html('')

handleChangeStream = ->
  $("#select-stream-type").on "change", ->
    switch $(this).val()
      when 'jpeg'
        destroyPlayer()
        $("#streams").removeClass("active").addClass "inactive"
        $("#fullscreen").removeClass("inactive").addClass "active"
        int_time = setInterval(loadImage, 1000)
      when 'video'
        $("#camera-video-stream").html(video_player_html)
        initializePlayer()
        $("#fullscreen").removeClass("active").addClass "inactive"
        $("#streams").removeClass("inactive").addClass "active"
        clearInterval int_time

handleTabOpen = ->
  $('.nav-tab-live').on 'show.bs.tab', ->
    if $('#select-stream-type').length
      $("#select-stream-type").trigger "change"
    else
      checkCameraOnline()

  $('.nav-tab-live').on 'hide.bs.tab', ->
    clearInterval int_time
    if $('#select-stream-type').length
      destroyPlayer()

  if $(".nav-tabs li.active a").attr("data-target") is "#live"
    if $('#select-stream-type').length
      $("#select-stream-type").trigger "change"
    else
      checkCameraOnline()

checkCameraOnline = ->
  if Evercam.Camera.is_online
    int_time = setInterval(loadImage, 1000)

saveImage = ->
  $('#save-live-snapshot').on 'click', ->
    clearInterval int_time
    refresh_paused = true
    data = {}
    data.with_data = true
    data.api_id = Evercam.User.api_id
    data.api_key = Evercam.User.api_key

    onError = (jqXHR, status, error) ->
      false

    onSuccess = (response) ->
      int_time = setInterval(loadImage, 1000)
      refresh_paused = false
      SaveImage.save(response.snapshots[0].data, "#{Evercam.Camera.id}-#{moment().toISOString()}.jpg")
      true

    settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      contentType: "application/json; charset=utf-8"
      type: 'GET'
      url: "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/recordings/snapshots/latest"
    sendAJAXRequest(settings)

window.initializeLiveTab = ->
  window.video_player_html = $('#camera-video-stream').html()
  window.vjs_player = {}
  image_placeholder = document.getElementById("live-player-image")
  controlButtonEvents()
  fullscreenImage()
  openPopout()
  handleChangeStream()
  handleTabOpen()
  saveImage()
