default_img = "/assets/offline.svg"
int_time = undefined
refresh_paused = false
image_placeholder = undefined
img_real_width = 0
img_real_height = 0

sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = $.ajax(settings)

loadImage = ->
  unless window.Evercam.Camera.cloud_recording.frequency == 60
    img = new Image()
    live_snapshot_url = "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/live/snapshot.jpg?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"
    src = "#{live_snapshot_url}&rand=" + new Date().getTime()
    img.src = src

controlButtonEvents = ->
  $(".play-pause").on "click", ->
    if refresh_paused
      int_time = setInterval(loadImage, 1000)
      refresh_paused = false
      $(this).children().removeClass "icon-control-play"
      $(this).children().addClass "icon-control-pause"
      disconnectFromSocket()
    else
      clearInterval int_time
      refresh_paused = true
      $(this).children().removeClass "icon-control-pause"
      $(this).children().addClass "icon-control-play"
      connectToSocket()
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
      window.open("/live/#{Evercam.Camera.id}", "_blank", "width=640, height=600, scrollbars=0")

initializePlayer = ->
  window.vjs_player = videojs 'camera-video-player', {techOrder: ["flash", "hls", "html5"]}
  $("#camera-video-player").append($("#ptz-control"))

destroyPlayer = ->
  unless $('#camera-video-stream').html() == ''
    $("#jpg-portion").append($("#ptz-control"))
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
        connectToSocket()
      when 'video'
        $("#camera-video-stream").html(video_player_html)
        initializePlayer()
        $("#fullscreen").removeClass("active").addClass "inactive"
        $("#streams").removeClass("inactive").addClass "active"
        clearInterval int_time
        disconnectFromSocket()

handleTabOpen = ->
  $('.nav-tab-live').on 'show.bs.tab', ->
    connectToSocket()
    if $('#select-stream-type').length
      $("#select-stream-type").trigger "change"
    else
      checkCameraOnline()

  $('.nav-tab-live').on 'hide.bs.tab', ->
    Evercam.socket.disconnect()
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

getImageRealRatio = ->
  $('<img/>').attr('src', $("#live-player-image").attr('src')).load ->
    img_real_width = @width
    img_real_height = @height
    if img_real_width is 0 && img_real_height is 0
      setTimeout(getImageRealRatio(), 1000)

calculateHeight = ->
  content_height = Metronic.getViewPort().height
  content_width = Metronic.getViewPort().width
  tab_menu_height = $("#ul-nav-tab").height()
  side_bar_width = $(".page-sidebar").width()
  image_height = content_height - (tab_menu_height *2)
  if $(".page-sidebar").css('display') is "none"
    content_width = content_width - side_bar_width

  $("#console-log").text("Real-Width: #{img_real_width}, content-width: #{content_width}")
  if $(".page-sidebar").css('display') is "none" && img_real_width > content_width
    image_height = img_real_height / img_real_width * content_width

  $("#live-player-image").css({"height": "#{image_height}px","max-height": "100%"})
  $(".offline-camera-placeholder img").css({"height": "#{image_height}px","max-height": "100%"})

handleResize = ->
  getImageRealRatio()
  calculateHeight()
  $(window).resize ->
    calculateHeight()

handlePtzCommands = ->
  $(".ptz-controls").on 'click', 'i', ->
    headingText = $('#ptz-control table thead tr th').text()
    $('#ptz-control table thead tr th').html 'Waiting <div class="loader"></div>'
    ptz_command = $(this).attr("data-val")
    if !ptz_command
      return
    api_url = "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/ptz/relative?#{ptz_command}&api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"
    if ptz_command is "home"
      api_url = "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/ptz/#{ptz_command}?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"
    data = {}

    onError = (jqXHR, status, error) ->
      $('#ptz-control table thead tr th').html headingText
      false

    onSuccess = (result) ->
      $('#ptz-control table thead tr th').html headingText
      true

    settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      contentType: "application/json; charset=utf-8"
      type: 'POST'
      url: api_url
    sendAJAXRequest(settings)

getPtzPresets = ->
  if !$(".ptz-controls").html()
    return
  data = {}
  data.api_id = Evercam.User.api_id
  data.api_key = Evercam.User.api_key

  onError = (jqXHR, status, error) ->
    false

  onSuccess = (result) ->
    for preset in result.Presets
      if preset.token < 33
        divPresets =$('<div>', {class: "row-preset"})
        divPresets.append($(document.createTextNode(preset.Name)))
        divPresets.attr("token_val", preset.token)
        $("#presets-table").append(divPresets)
    true

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    contentType: "application/json; charset=utf-8"
    type: 'GET'
    url: "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/ptz/presets"
  sendAJAXRequest(settings)

changePtzPresets = ->
  $("#camera-presets").on 'click', '.row-preset', ->
    data = {}

    onError = (jqXHR, status, error) ->
      false

    onSuccess = (result) ->
      true

    settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      contentType: "application/json; charset=utf-8"
      type: 'POST'
      url: "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/ptz/presets/go/#{$(this).attr("token_val")}?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"
    sendAJAXRequest(settings)
    $('#camera-presets').modal('hide')

handleModelEvents = ->
  $("#camera-presets").on "show.bs.modal", ->
    $("#ptz-control").addClass("hide")

  $("#camera-presets").on "hidden.bs.modal", ->
    $("#ptz-control").removeClass("hide")
    $('#ptz-control table thead tr th').html 'PTZ'

initSocket = ->
  window.Evercam.socket = new (Phoenix.Socket)(Evercam.websockets_url)
  connectToSocket()

connectToSocket = ->
  Evercam.socket.connect()
  channel = Evercam.socket.channel("cameras:#{Evercam.Camera.id}", {})
  channel.join()
  channel.on 'snapshot-taken', (payload) ->
    $('#live-player-image').attr 'src', 'data:image/jpeg;base64,' + payload.image

disconnectFromSocket = ->
  Evercam.socket.disconnect()

checkPTZExist = ->
  if $(".ptz-controls").length > 0
    $('.live-options').css('top','114px').css('right','32px')

window.initializeLiveTab = ->
  initSocket()
  window.video_player_html = $('#camera-video-stream').html()
  window.vjs_player = {}
  image_placeholder = document.getElementById("live-player-image")
  controlButtonEvents()
  fullscreenImage()
  openPopout()
  handleChangeStream()
  handleTabOpen()
  saveImage()
  handleResize()
  handlePtzCommands()
  getPtzPresets()
  changePtzPresets()
  handleModelEvents()
  checkPTZExist()
