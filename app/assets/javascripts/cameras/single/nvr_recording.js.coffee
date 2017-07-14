retries = 0
showFeedback = (message) ->
  Notification.show(message)

get_thumbnails = (from, to, item) ->
  #if item is 1
  #  load_stream(from, to)
  $("#thumb_item#{item}").show()
  data =
    api_id: Evercam.User.api_id
    api_key: Evercam.User.api_key

  onSuccess = (response) ->
    if response.snapshots.length > 0
      display_thumbnail(response.snapshots[0], this.item, this.from, this.to)
    else
      display_thumbnail({data: "/assets/offline.png", created_at: this.from, notes: ""}, this.item, this.from, this.to)

  onError = (jqXHR, status, error) ->
    display_thumbnail({data: "/assets/offline.png", created_at: this.from, notes: ""}, this.item, this.from, this.to)

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    context: {item: item, from: from, to: to}
    type: 'GET'
    url: "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/recordings/snapshots/#{from}/nearest"

  $.ajax(settings)

display_thumbnail = (snapshot, item, from, to) ->
  image_date = moment.utc(from*1000)
  $("#thumb_item#{item}").show()
  image = $("#thumb_item#{item} img")
  image.attr("src", snapshot.data)
  image.attr("notes", snapshot.notes)
  image.attr("timestamp", snapshot.created_at)
  image.attr("from", from)
  image.attr("to", to)
  $("#thumb_item#{item} div.time-div").text("#{FormatNumTo2(image_date.hours())}:#{FormatNumTo2(image_date.minutes())}:#{FormatNumTo2(image_date.seconds())}")

load_stream = (from, to) ->
  onSuccess = (response) ->
    re_init_player()

  onError = (jqXHR, status, error) ->
    Notification.show("Something went wrong, Please try again.")

  query_string = "?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"
  query_string += "&starttime=#{from}&endtime=#{to}"

  settings =
    cache: false
    data: {}
    dataType: 'json'
    error: onError
    success: onSuccess
    type: 'GET'
    url: "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/nvr/stream#{query_string}"

  $.ajax(settings)

initializePlayer = ->
  window.vjs_player_local = videojs('local-recording-video-player')
  $("#local-recording-video-player").append($("#div-capture"))

re_init_player = ->
  $("#live-view-placeholder").append($("#div-capture"))
  window.vjs_player_local.dispose()
  $("#local-recording-stream").html(local_video_player_html)
  initializePlayer()
  set_position()
  $("#local-recording-video-player").append($("#div-capture"))
  window.vjs_player_local.poster($("#captured").attr("src"))
  setTimeout(set_stream_source, 2000)

set_stream_source = ->
  if window.vjs_player_local.error() && retries < 6
    window.vjs_player_local.src([
      { type: "application/x-mpegURL", src: "https://media.evercam.io/hls/#{Evercam.Camera.id}/index.m3u8?nvr=true" },
      { type: "rtmp/flv", src: "rtmp://media.evercam.io:1935/live/#{Evercam.Camera.id}?nvr=true" }
    ])
    $("#local-recording-video-player div.vjs-error-display").hide()
    retries = retries + 1
    setTimeout(set_stream_source, 2000)

initDatePicker = ->
  $("#ui_date_picker_inline_lr").datepicker().on("changeDate", datePickerSelect).on "changeMonth", datePickerChange
  $("#ui_date_picker_inline_lr table th[class*='prev']").on "click", ->
    #changeMonthFromArrow('p')
    true

  $("#ui_date_picker_inline_lr table th[class*='next']").on "click", ->
    #changeMonthFromArrow('n')
    true

  $("#local_recording_hourCalendar td[class*='day']").on "click", ->
    $("#lr-md-slider-item li").hide()
    $("#lr-md-slider-item img").attr("src", "")
    loadRecordingStream(parseInt($(this).html()), "lr_tdI#{$(this).html()}")

datePickerSelect = (value)->
  dt = value.date

datePickerChange=(value)->
  d = value.date
  year = d.getFullYear()
  month = d.getMonth() + 1
  #walkDaysInMonth(year, month)

loadRecordingStream = (hour, hour_id) ->
  $("#local_recording_hourCalendar td").removeClass("active")
  $("##{hour_id}").addClass("active")
  currentDate = $("#camera_selected_time").val()
  currentHour = parseInt($("#camera_current_time").val())
  date = $("#ui_date_picker_inline_lr").datepicker('getDate')
  current_camera_date = moment(date).format('MM/DD/YYYY')
  minutes = 60
  if currentDate is current_camera_date && currentHour is hour
    minutes = moment.utc().minutes()
  year = date.getFullYear()
  month = date.getMonth() + 1
  day = date.getDate()
  hr = parseInt(hour)
  num = 0
  item = 1
  while num < minutes
    from = moment.tz("#{year}-#{month}-#{day} #{hr}:#{num}", Evercam.Camera.timezone) / 1000
    to = moment.tz("#{year}-#{month}-#{day} #{hr}:#{num + 4}:59", Evercam.Camera.timezone) / 1000
    get_thumbnails(from, to, item)
    num = num + 5
    item = item + 1

FormatNumTo2 = (n) ->
  if n < 10
    "0#{n}"
  else
    n

on_click_timestamp = ->
  $("#lr-md-slider-item li").on "click", ->
    $("#lr-md-slider-item li").removeClass("active")
    $(this).addClass("active")
    from = $(this).find("img").attr("from")
    to = $(this).find("img").attr("to")
    $("#captured").attr("src", $(this).attr("src"))
    load_stream(from, to)

capture_image = ->
  $("#div-capture").on "click", ->
    $pop = Popcorn("#local-recording-video-player_html5_api");
    $pop.capture
      set: false
      target: "img#captured"
      reload: false
    SaveImage.save($("#captured").attr('src'), "#{Evercam.Camera.id}.png")

set_position = ->
  content_width = Metronic.getViewPort().width
  content_height = Metronic.getViewPort().height
  content_height = content_height - $('.center-tabs').height()
  side_bar_width = $(".page-sidebar").width()
  if $(".page-sidebar").css('display') is "block"
    content_width = content_width - side_bar_width;
  $("#local_recordings_tab .left-column").css("width", "#{content_width - 225}px")
  $("#local_recordings_tab .right-column").css("width", "220px")
  $("#local_recordings_tab #live-view-placeholder").css("height", "#{content_height - 120}px")
  $("#local_recordings_tab #local-recording-video-player").css("height", "#{content_height - 120}px")
  $("#local-recording-video-player_html5_api").css("height", "#{content_height - 120}px")

handleResize = ->
  set_position()
  $(window).resize ->
    set_position()

handleTabOpen = ->
  $('.nav-tab-local-recordings').on 'shown.bs.tab', ->
    set_position()

on_ended_play = ->
  window.vjs_player_local.on "ended", ->
    false

  window.vjs_player_local.on "error", ->
    $("#local-recording-video-player div.vjs-error-display").hide()

window.initializeLocalRecordingsTab = ->
  $("#lr-md-slider-item li").hide()
  current_hour = parseInt($("#camera_current_time").val())
  $("#lr_tdI#{current_hour}").addClass("active")
  window.local_video_player_html = $('#local-recording-stream').html()
  window.vjs_player_local = {}
  initDatePicker()
  initializePlayer()
  on_click_timestamp()
  loadRecordingStream(current_hour, "lr_tdI#{current_hour}")
  handleResize()
  handleTabOpen()
  capture_image()
  on_ended_play()
  $("#btnplayer").on "click", ->
    console.log window.vjs_player_local.error()
