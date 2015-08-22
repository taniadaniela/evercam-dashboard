#= require cameras/single/cloud_recording_schedule.js.coffee

snapshotInfos = null
totalFrames = 0
snapshotInfoIdx = 0
currentFrameNumber = 0
cameraCurrentHour = 0;
PreviousImageHour = "tdI8"
BoldDays = null
ClearCalanderTimeOut = null
isPlaying = false
PauseAfterPlay = false
playInterval = 250
ChunkSize = 3600
normalSpeed = 1000
totalSnaps = 0
changedPlayFrom = ""
limit = ChunkSize
sliderpercentage = 679
playDirection = 1
playStep = 1
CameraOffset = 0
xhrRequestChangeMonth = null
playFromDateTime = null
playFromTimeStamp = null

showFeedback = (message) ->
  Notification.show(message)

sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = $.ajax(settings)

initDatePicker = ->
  $("#ui_date_picker_inline").datepicker().on("changeDate", datePickerSelect).on "changeMonth", datePickerChange
  $("#ui_date_picker_inline table th[class*='prev']").on "click", ->
    changeMonthFromArrow('p')

  $("#ui_date_picker_inline table th[class*='next']").on "click", ->
    changeMonthFromArrow('n')

  $("#hourCalandar td[class*='day']").on "click", ->
    SetImageHour $(this).html(), "tdI#{$(this).html()}"

changeMonthFromArrow = (value) ->
  xhrRequestChangeMonth.abort()
  $("#ui_date_picker_inline").datepicker('fill');
  d = $("#ui_date_picker_inline").datepicker('getDate');
  day = d.getMonth()
  year = d.getFullYear()
  if value is 'n'
    day = day + 2
  if day is 13
    day = 1
    year++
  if day is 0
    day = 12
    year--
  cameraId = Evercam.Camera.id

  data = {}
  data.api_id = Evercam.User.api_id
  data.api_key = Evercam.User.api_key
  onError = (jqXHR, status, error) ->
    false

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: HighlightCurrentMonthSuccess
    contentType: "application/json; charset=utf-8"
    type: 'GET'
    url: "#{Evercam.API_URL}cameras/#{cameraId}/recordings/snapshots/#{year}/#{day}/days.json"

  sendAJAXRequest(settings)
  if value =='n'
    d.setMonth(d.getMonth()+1)
  else if value =='p'
    d.setMonth(d.getMonth()-1)
  $("#ui_date_picker_inline").datepicker('setDate',d);
  snapshotInfos = null
  snapshotInfoIdx = 1
  currentFrameNumber = 0

datePickerSelect = (value)->
  dt = value.date
  $("#divPointer").width(0)
  $("#divSlider").width(0)
  $("#ddlRecMinutes").val(0)
  $("#ddlRecSeconds").val(0)
  $("#divDisableButtons").removeClass("hide").addClass("show")
  $("#divFrameMode").removeClass("show").addClass("hide")
  $("#divPlayMode").removeClass("show").addClass("hide")
  hasDayRecord = false
  for j in BoldDays
    if j == dt.getDate()
      hasDayRecord = true
      break

  clearHourCalander()
  if hasDayRecord
    BoldSnapshotHour(false)
  else
    NoRecordingDayOrHour()

  ClearCalanderTimeOut = setTimeout(ResetDays, 100);

datePickerChange=(value)->
  d = value.date
  cameraId = Evercam.Camera.id

  data = {}
  data.api_id = Evercam.User.api_id
  data.api_key = Evercam.User.api_key
  onError = (jqXHR, status, error) ->
    false

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: HighlightCurrentMonthSuccess
    contentType: "application/json; charset=utf-8"
    type: 'GET'
    url: "#{Evercam.API_URL}cameras/#{cameraId}/recordings/snapshots/#{d.getFullYear()}/#{(d.getMonth() + 1)}/days.json"

  sendAJAXRequest(settings)
  snapshotInfos = null
  snapshotInfoIdx = 1
  currentFrameNumber = 0

clearHourCalander = ->
  $("#hourCalandar td[class*='day']").removeClass("active")
  calDays = $("#hourCalandar td[class*='day']")
  calDays.each ->
    calDay = $(this)
    calDay.removeClass('has-snapshot')

ResetDays = ->
  clearTimeout ClearCalanderTimeOut
  return  unless BoldDays?
  calDays = $("#ui_date_picker_inline table td[class*='day']")
  calDays.each (idx, el) ->
    calDay = $(this)
    if !calDay.hasClass('old') && !calDay.hasClass('new')
      iDay = parseInt(calDay.text())
      j = 0
      while j < BoldDays.length
        if BoldDays[j] is iDay
          calDay.addClass('has-snapshot')
          break
        j++

selectCurrentDay = ->
  $(".datepicker-days table td[class*='day']").removeClass('active')
  dt = $("#ui_date_picker_inline").datepicker('getDate')
  calDays = $(".datepicker-days table td[class*='day']")
  calDays.each (idx, el) ->
    calDay = $(this)
    if !calDay.hasClass('old') && !calDay.hasClass('new')
      iDay = parseInt(calDay.text())
      if dt.getDate() is iDay
        calDay.addClass('active')
        return

handleSlider = ->
  onSliderMouseMove = (ev) ->
    if snapshotInfos == null || snapshotInfos.length == 0 then return

    sliderStartX = $("#divSlider").offset().left
    sliderEndX = sliderStartX + $("#divSlider").width()

    pos = (ev.pageX - sliderStartX) / (sliderEndX - sliderStartX)
    if pos < 0
      pos = 0

    idx = Math.round(pos * totalFrames)
    if (idx > totalFrames - 1)
      idx = totalFrames - 1

    x = ev.pageX - 80
    if x > sliderEndX - 80
      x = sliderEndX - 80
    motionVal = ""
    frameNo = idx + 1
    $("#divPopup").html("Frame #{frameNo}, #{shortDate(new Date(snapshotInfos[idx].created_at*1000)) + motionVal}")
    $("#divPopup").show()
    $("#divPopup").offset({ top: ev.pageY + 20, left: x })

    $("#divSlider").css('background-position', "#{(ev.pageX - sliderStartX)}px 0px")
    $("#divPointer").css('background-position', "#{(ev.pageX - sliderStartX)}px 0px")

  $("#divSlider").mousemove(onSliderMouseMove)

  onSliderMouseOut = ->
    $("#divPopup").hide()
    $("#divSlider").css('background-position', '-3px 0px')
    $("#divPointer").css('background-position', '-3px 0px')

  $("#divSlider").mouseout(onSliderMouseOut)

  onSliderClick = (ev) ->
    sliderStartX = $("#divSlider").offset().left
    sliderEndX = sliderStartX + $("#divSlider").width()
    x = ev.pageX - sliderStartX
    percent = x / (sliderEndX - sliderStartX)
    nextFrameNum = parseInt(totalFrames * percent)

    if nextFrameNum < 0
      nextFrameNum = 0
    if nextFrameNum > totalFrames
      nextFrameNum = totalFrames
    if nextFrameNum is totalFrames || nextFrameNum is snapshotInfoIdx
      return
    showLoader()
    snapshotInfoIdx = nextFrameNum
    currentFrameNumber = snapshotInfoIdx + 1
    UpdateSnapshotRec(snapshotInfos[nextFrameNum])

  $("#divSlider").click(onSliderClick)

showLoader = ->
  if $("#imgPlayback").attr("src").indexOf('nosnapshots') != -1
    $("#imgPlayback").attr("src","/assets/plain.png")
  $("#imgLoaderRec").width($('#imgPlayback').width())
  $("#imgLoaderRec").height($('#imgPlayback').height())
  $("#imgLoaderRec").css("top", $('#imgPlayback').css('top'))
  $("#imgLoaderRec").css("left", $('#imgPlayback').css('left'))
  $("#imgLoaderRec").show()

SetInfoMessage = (currFrame, date_time) ->
  $("#divInfo").fadeIn()
  $("#snapshot-notes-text").show()
  $("#divInfo").html("<span class='snapshot-frame'>#{currFrame} of #{totalSnaps}</span> <span class='snapshot-date'>#{shortDate(date_time)}</span>")
  totalWidth = $("#divSlider").width()
  $("#divPointer").width(totalWidth * currFrame / totalFrames)
  url = "#{Evercam.request.rootpath}/recordings/snapshots/#{moment.utc(date_time).toISOString()}"

  if $(".nav-tabs li.active a").html() is "Recordings" && history.replaceState
    window.history.replaceState({}, '', url);

UpdateSnapshotRec = (snapInfo) ->
  showLoader()
  $("#snapshot-notes-text").text(snapInfo.notes)
  SetInfoMessage currentFrameNumber, new Date(snapInfo.created_at*1000)
  loadImage(snapInfo.created_at)

getTimestampFromUrl = ->
  timestamp = window.Evercam.request.subpath.
    replace(RegExp("recordings", "g"), "").
    replace(RegExp("snapshots", "g"), "").
    replace(RegExp("/", "g"), "")
  if isValidDateTime(timestamp)
    return timestamp
  else
    return ""

isValidDateTime = (timestamp) ->
  moment(timestamp, "YYYY-MM-DDTHH:mm:ss.SSSZ", true).isValid()

handleBodyLoadContent = ->
  offset = $('#camera_time_offset').val()
  CameraOffset = parseInt(offset)/3600
  currentDate = new Date($("#camera_selected_time").val())
  cameraCurrentHour = currentDate.getHours()
  $("#hourCalandar td[class*='day']").removeClass("active")

  timestamp = getTimestampFromUrl()
  if timestamp isnt ""
    playFromTimeStamp = moment.utc(timestamp)/1000
    playFromDateTime = new Date(moment.utc(timestamp).format('MM/DD/YYYY HH:mm:ss'))
    playFromDateTime.setHours(playFromDateTime.getHours() + (CameraOffset))
    currentDate = playFromDateTime
    cameraCurrentHour = currentDate.getHours()
    $("#ui_date_picker_inline").datepicker('update', currentDate)

  $("#tdI#{cameraCurrentHour}").addClass("active")
  PreviousImageHour = "tdI#{cameraCurrentHour}"
  $("#ui_date_picker_inline").datepicker('setDate', currentDate)
  selectCurrentDay()
  $(".btn-group").tooltip()

  showLoader()
  HighlightCurrentMonth()
  BoldSnapshotHour(false)

fullscreenImage = ->
  $("#imgPlayback").dblclick ->
    screenfull.toggle $(this)[0]

  if screenfull.enabled
    document.addEventListener screenfull.raw.fullscreenchange, ->
      if screenfull.isFullscreen
        $("#imgPlayback").css('width','auto')
      else
        $("#imgPlayback").css('width','100%')

getLocationBaseDateTime = (offset) ->
  #create Date object for current location
  d = new Date()
  #d.getTimezoneOffset() Returns the time difference between UTC time and local time, in minutes
  utc = d.getTime() + (d.getTimezoneOffset() * 60000)
  #create new Date object for different Location using supplied offset
  utc = (utc + parseInt(offset))
  nd = new Date(utc)
  return nd

HighlightCurrentMonth = ->
  d = $("#ui_date_picker_inline").datepicker('getDate');
  cameraId = Evercam.Camera.id

  data = {}
  data.api_id = Evercam.User.api_id
  data.api_key = Evercam.User.api_key
  onError = (jqXHR, status, error) ->
    false

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: HighlightCurrentMonthSuccess
    contentType: "application/json; charset=utf-8"
    type: 'GET'
    url: "#{Evercam.API_URL}cameras/#{cameraId}/recordings/snapshots/#{d.getFullYear()}/#{(d.getMonth() + 1)}/days.json"

  sendAJAXRequest(settings)

HighlightCurrentMonthSuccess = (results, status, jqXHR) ->
  calDays = $("#ui_date_picker_inline table td[class*='day']")
  BoldDays = results.days
  calDays.each ->
    calDay = $(this)
    if !calDay.hasClass('old') && !calDay.hasClass('new')
      iDay = parseInt(calDay.text())
      for result in results.days
        if result == iDay
          calDay.addClass('has-snapshot')
          if playFromDateTime isnt null && playFromDateTime.getDate() == iDay
            calDay.addClass('active')
          break

BoldSnapshotHour = (callFromDt) ->
  $("#divDisableButtons").removeClass("hide").addClass("show")
  $("#divFrameMode").removeClass("show").addClass("hide")
  $("#divPlayMode").removeClass("show").addClass("hide")
  d = $("#ui_date_picker_inline").datepicker('getDate');
  cameraId = Evercam.Camera.id

  data = {}
  data.api_id = Evercam.User.api_id
  data.api_key = Evercam.User.api_key
  onError = (jqXHR, status, error) ->
    false

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: BoldSnapshotHourSuccess
    context: { isCall: callFromDt }
    contentType: "application/json; charset=utf-8"
    type: 'GET'
    url: "#{Evercam.API_URL}cameras/#{cameraId}/recordings/snapshots/#{d.getFullYear()}/#{(d.getMonth() + 1)}/#{d.getDate()}/hours.json"

  sendAJAXRequest(settings)

BoldSnapshotHourSuccess = (result, context) ->
  lastBoldHour = 0;
  hasRecords = false;
  for hour in result.hours
    #hr = hour + CameraOffset
    $("#tdI#{hour}").addClass('has-snapshot')
    lastBoldHour = hour
    hasRecords = true

  if hasRecords
    if this.isCall
      GetCameraInfo true
    else
      if playFromDateTime isnt null
        lastBoldHour = cameraCurrentHour
      SetImageHour(lastBoldHour, "tdI#{lastBoldHour}")
  else
    NoRecordingDayOrHour()

GetCameraInfo = (isShowLoader) ->
  $("#divDisableButtons").removeClass("hide").addClass("show")
  $("#divFrameMode").removeClass("show").addClass("hide")
  $("#divPlayMode").removeClass("show").addClass("hide")
  if isShowLoader
    showLoader()
  fromDT = GetFromDT()/1000
  toDT = GetToDT()/1000

  cameraId = Evercam.Camera.id

  data = {}
  data.from = fromDT
  data.to = toDT
  data.limit = limit
  data.page = 1
  data.api_id = Evercam.User.api_id
  data.api_key = Evercam.User.api_key
  onError = (jqXHR, status, error) ->
    false
  onSuccess = (response) ->
    snapshotInfoIdx = 0
    snapshotInfos = response.snapshots
    totalFrames = response.snapshots.length
    totalSnaps = response.snapshots.length
    if response == null || response.snapshots.length == 0
      $("#divSliderMD").width("100%")
      $("#MDSliderItem").html("")
      $("#divNoMd").show()
      NoRecordingDayOrHour()
      HideLoader()
    else
      $("#divDisableButtons").removeClass("show").addClass("hide")
      $("#divFrameMode").removeClass("hide").addClass("show")
      iterations = Math.ceil(totalSnaps / ChunkSize)
      sliderpercentage = Math.ceil(100 / iterations)

      if sliderpercentage > 100
        sliderpercentage = 100
      $("#divSlider").width("#{sliderpercentage}%")
      currentFrameNumber=1
      frameDateTime = new Date(snapshotInfos[snapshotInfoIdx].created_at*1000)
      snapshotTimeStamp = snapshotInfos[snapshotInfoIdx].created_at

      if playFromDateTime isnt null
        snapshotTimeStamp = SetPlayFromImage playFromTimeStamp
        frameDateTime = new Date(snapshotTimeStamp*1000)
        if currentFrameNumber isnt 1
          playFromDateTime = null
          playFromTimeStamp = null

      $("#snapshot-notes-text").text(snapshotInfos[snapshotInfoIdx].notes)
      SetInfoMessage(currentFrameNumber, frameDateTime)
      loadImage(snapshotTimeStamp)
    true

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    contentType: "application/json; charset=utf-8"
    type: 'GET'
    url: "#{Evercam.API_URL}cameras/#{cameraId}/recordings/snapshots.json"

  sendAJAXRequest(settings)

loadImage = (timestamp) ->
  cameraId = Evercam.Camera.id

  data = {}
  data.with_data = true
  data.range = 1
  data.api_id = Evercam.User.api_id
  data.api_key = Evercam.User.api_key

  onError = (jqXHR, status, error) ->
    false

  onSuccess = (response) ->
    if response.snapshots.length > 0
      $("#snapshot-tab-save").show()
      $("#imgPlayback").attr("src", response.snapshots[0].data)
    HideLoader()
    true

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    contentType: "application/json; charset=utf-8"
    type: 'GET'
    url: "#{Evercam.API_URL}cameras/#{cameraId}/recordings/snapshots/#{timestamp}.json"

  sendAJAXRequest(settings)

SetPlayFromImage = (timestamp) ->
  i = 0
  for snapshot in snapshotInfos
    snapshot_timestamp = GetUTCDate(new Date(getSnapshotDate(new Date(snapshot.created_at*1000)).format('MM/DD/YYYY HH:mm:ss')))/1000
    if snapshot.created_at >= timestamp
      currentFrameNumber = i + 1
      snapshotInfoIdx = i
      return snapshot.created_at
    i++
  currentFrameNumber = snapshotInfos.length
  snapshotInfoIdx = snapshotInfos.length - 1
  return snapshotInfos[snapshotInfoIdx].created_at

GetUTCDate = (date) ->
  UtcDate = Date.UTC(date.getFullYear(), date.getMonth(), date.getDate(), date.getHours(), date.getMinutes(), date.getSeconds())
  return UtcDate

shortDate = (date) ->
  dt = $("#ui_date_picker_inline").datepicker('getDate')
  hour = parseInt(cameraCurrentHour)
  return "#{FormatNumTo2(dt.getDate())}/#{FormatNumTo2(dt.getMonth()+1)}/#{date.getFullYear()} #{FormatNumTo2(hour)}:#{FormatNumTo2(date.getMinutes())}:#{FormatNumTo2(date.getSeconds())}"

getSnapshotDate = (date) ->
  dt = $("#ui_date_picker_inline").datepicker('getDate')
  hour = parseInt(cameraCurrentHour)
  return moment.utc([dt.getFullYear(), dt.getMonth(), dt.getDate(), hour, date.getMinutes(), date.getSeconds(), date.getMilliseconds()])

GetFromDT = ->
  d = $("#ui_date_picker_inline").datepicker('getDate')
  hour = parseInt(cameraCurrentHour)
  fDt = Date.UTC(d.getFullYear(), d.getMonth(), d.getDate(), hour, 0, 0)
  return fDt

GetToDT = ->
  d = $("#ui_date_picker_inline").datepicker('getDate')
  hour = parseInt(cameraCurrentHour) + 1
  tDt = 0
  if hour == 24
    tDt = Date.UTC(d.getFullYear(), d.getMonth(), d.getDate(), 23, 59, 59)
  else
    tDt = Date.UTC(d.getFullYear(), d.getMonth(), d.getDate(), hour, 0, 0)
  return tDt

StripLeadingZeros = (input) ->
  if input.length > 1 && input.substr(0,1) == "0"
    return input.substr(1)
  else
    return input

FormatNumTo2 = (n) ->
  if n < 10
    return "0#{n}"
  else
    return n

NoRecordingDayOrHour = ->
  $("#divRecent").show()
  $("#imgPlayback").attr("src", "/assets/nosnapshots.svg")
  $("#divInfo").fadeOut()
  $("#divPointer").width(0)
  $("#divSliderBackground").width(0)

  $("#MDSliderItem").html("")
  $("#divNoMd").show()
  $("#divNoMd").text('No motion detected')
  HideLoader()

  totalFrames = 0;

SetImageHour = (hr, id) ->
  value = $("##{id}").html()
  $("#ddlRecMinutes").val(0)
  $("#ddlRecSeconds").val(0)
  cameraCurrentHour = hr
  $("##{PreviousImageHour}").removeClass("active")
  $("##{id}").addClass("active")
  PreviousImageHour = id
  snapshotInfos = null
  Pause()
  currentFrameNumber = 0
  $("#divPointer").width(0)
  $("#divSlider").width("0%")
  $("#divDisableButtons").removeClass("hide").addClass("show")
  $("#divFrameMode").removeClass("show").addClass("hide")
  $("#divPlayMode").removeClass("show").addClass("hide")

  if $("##{id}").hasClass('has-snapshot')
    $("#divSliderBackground").width("100%")
    $("#divSliderMD").width("100%")
    $("#MDSliderItem").html("")
    $("#divNoMd").show()
    $("#btnCreateHourMovie").removeAttr('disabled')
    GetCameraInfo true
  else
    xhrRequestChangeMonth.abort()
    $("#divRecent").show()
    $("#divInfo").fadeOut()
    $("#snapshot-notes-text").hide()
    $("#divSliderBackground").width("0%")
    $("#txtCurrentUrl").val("")
    $("#divSliderMD").width("100%")
    $("#MDSliderItem").html("")
    $("#btnCreateHourMovie").attr('disabled', true)
    totalFrames = 0
    $("#imgPlayback").attr("src", "/assets/nosnapshots.svg")
    $("#divNoMd").show()
    $("#divNoMd").text('No motion detected')
    HideLoader()
    $("#snapshot-tab-save").hide()
  true

Pause = ->
  isPlaying = false
  $("#divFrameMode").removeClass("hide").addClass("show")
  $("#divPlayMode").removeClass("show").addClass("hide")
  PauseAfterPlay = true

HideLoader = ->
  $("#imgLoaderRec").hide();

handleWindowResize = ->
  $(window).on "resize", ->
    totalWidth = $("#divSlider").width()
    $("#divPointer").width(totalWidth * currentFrameNumber / totalFrames)

handlePlay = ->
  $("#btnPlayRec").on "click", ->
    return  if totalFrames is 0

    playDirection = 1
    playStep = 1
    $("#divFrameMode").removeClass("show").addClass("hide")
    $("#divPlayMode").removeClass("hide").addClass("show")
    isPlaying = true
    if snapshotInfos.length is snapshotInfoIdx + 1
      snapshotInfoIdx = 0
      currentFrameNumber = 1
    DoNextImg()

  $("#btnPauseRec").on "click", ->
    Pause()

  $("#btnFRwd").on "click", ->
    SetPlaySpeed 10, -1

  $("#btnRwd").on "click", ->
    SetPlaySpeed 5, -1

  $("#btnFFwd").on "click", ->
    SetPlaySpeed 10, 1

  $("#btnFwd").on "click", ->
    SetPlaySpeed 5, 1

  $(".skipframe").on "click", ->
    switch $(this).html()
      when "+1" then SetSkipFrames 1, "n"
      when "+5" then SetSkipFrames 5, "n"
      when "+10" then SetSkipFrames 10, "n"
      when "+100" then SetSkipFrames 100, "n"
      when "-1" then SetSkipFrames 1, "p"
      when "-5" then SetSkipFrames 5, "p"
      when "-10" then SetSkipFrames 10, "p"
      when "-100" then SetSkipFrames 100, "p"

SetSkipFrames = (num, direction) ->
  if direction is "p"
    return  if snapshotInfoIdx is 0
    if snapshotInfoIdx - num < 0
      currentFrameNumber = 1
      snapshotInfoIdx = 0
    else
      currentFrameNumber = currentFrameNumber - num
      snapshotInfoIdx = snapshotInfoIdx - num
  else if direction is "n"
    return  if snapshotInfos.length is snapshotInfoIdx + 1
    if snapshotInfoIdx + num > snapshotInfos.length - 1
      snapshotInfoIdx = snapshotInfos.length - 1
      currentFrameNumber = snapshotInfos.length
    else
      currentFrameNumber = currentFrameNumber + num
      snapshotInfoIdx = snapshotInfoIdx + num
  PauseAfterPlay = false
  playDirection = 1

  UpdateSnapshotRec snapshotInfos[snapshotInfoIdx]
  return

SetPlaySpeed = (step, direction) ->
  playDirection = direction
  playStep = step

DoNextImg = ->
  return  if totalFrames is 0
  if snapshotInfos.length is snapshotInfoIdx
    Pause()
    currentFrameNumber = snapshotInfos.length
    snapshotInfoIdx = snapshotInfos.length - 1
  si = snapshotInfos[snapshotInfoIdx]
  cameraId = Evercam.Camera.id

  data = {}
  data.with_data = true
  data.range = 1
  data.api_id = Evercam.User.api_id
  data.api_key = Evercam.User.api_key

  onError = (jqXHR, status, error) ->
    if playDirection is 1 and playStep is 1
      currentFrameNumber++
      snapshotInfoIdx++
    else if playDirection is 1 and playStep > 1
      currentFrameNumber = currentFrameNumber + playStep
      currentFrameNumber = snapshotInfos.length  if currentFrameNumber >= snapshotInfos.length
      snapshotInfoIdx = snapshotInfoIdx + playStep
      snapshotInfoIdx = snapshotInfos.length - 1  if snapshotInfoIdx > snapshotInfos.length - 1
    else if playDirection is -1 and playStep > 1
      currentFrameNumber = currentFrameNumber - playStep
      currentFrameNumber = 1  if currentFrameNumber <= 1
      snapshotInfoIdx = snapshotInfoIdx - playStep
      snapshotInfoIdx = 0  if snapshotInfoIdx < 0
      Pause()  if snapshotInfoIdx is 0
    window.setTimeout DoNextImg, playInterval  if isPlaying
    false

  onSuccess = (response) ->
    if response.snapshots.length > 0
      SetInfoMessage currentFrameNumber, new Date(si.created_at*1000)
    $("#imgPlayback").attr("src", response.snapshots[0].data)

    if playDirection is 1 and playStep is 1
      currentFrameNumber++
      snapshotInfoIdx++
    else if playDirection is 1 and playStep > 1
      currentFrameNumber = currentFrameNumber + playStep
      currentFrameNumber = snapshotInfos.length  if currentFrameNumber >= snapshotInfos.length
      snapshotInfoIdx = snapshotInfoIdx + playStep
      snapshotInfoIdx = snapshotInfos.length - 1  if snapshotInfoIdx > snapshotInfos.length - 1
    else if playDirection is -1 and playStep > 1
      currentFrameNumber = currentFrameNumber - playStep
      currentFrameNumber = 1  if currentFrameNumber <= 1
      snapshotInfoIdx = snapshotInfoIdx - playStep
      snapshotInfoIdx = 0  if snapshotInfoIdx < 0
      Pause()  if snapshotInfoIdx is 0

    window.setTimeout DoNextImg, playInterval  if isPlaying

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    contentType: "application/json; charset=utf-8"
    type: 'GET'
    url: "#{Evercam.API_URL}cameras/#{cameraId}/recordings/snapshots/#{si.created_at}.json"

  sendAJAXRequest(settings)

SelectImagesByMinSec = ->
  min = FormatNumTo2($("#ddlRecMinutes").val())
  sec = FormatNumTo2($("#ddlRecSeconds").val())
  estimatedIndex = Math.round((snapshotInfos.length / 60) * parseInt(min))
  if estimatedIndex < snapshotInfos.length - 1
    i = 0

    while i < snapshotInfos.length
      si = snapshotInfos[i]

      sDt = si.date.substring(si.date.indexOf(" ") + 1).split(":")
      if sDt[1] is min
        if sDt[2] is sec
          currentFrameNumber = i + 1
          snapshotInfoIdx = i
          UpdateSnapshotRec si
        else if sDt[2] > sec
          currentFrameNumber = i
          snapshotInfoIdx = i - 1
          si = snapshotInfos[snapshotInfoIdx]
          sDt = si.date.substring(si.date.indexOf(" ") + 1).split(":")
          $("#ddlRecSeconds").val sDt[2]
          UpdateSnapshotRec si
      else if sDt[1] > min
        currentFrameNumber = i
        snapshotInfoIdx = i - 1
        si = snapshotInfos[snapshotInfoIdx]
        sDt = si.date.substring(si.date.indexOf(" ") + 1).split(":")
        $("#ddlRecSeconds").val sDt[2]
        UpdateSnapshotRec si
      i++
  else
    currentFrameNumber = snapshotInfos.length + 1
    snapshotInfoIdx = snapshotInfos.length
    UpdateSnapshotRec snapshotInfos[snapshotInfoIdx]

handleMinSecDropDown = ->
  hour = 1

  while hour <= 59
    option = $("<option>").val(FormatNumTo2(hour)).append(FormatNumTo2(hour))
    $("#ddlRecMinutes").append option
    option = $("<option>").val(FormatNumTo2(hour)).append(FormatNumTo2(hour))
    $("#ddlRecSeconds").append option
    hour++
  $("#ddlRecMinutes").on "change", ->
    SelectImagesByMinSec()

  $("#ddlRecSeconds").on "change", ->
    SelectImagesByMinSec()

  $('#show-info').click ->
    $('#snapshot-notes-text').toggle()
  return

handleTabOpen = ->
  $('.nav-tab-recordings').on 'show.bs.tab', ->
    #showLoader()
    #HighlightCurrentMonth()
    #BoldSnapshotHour(false)
    if snapshotInfos isnt null
      date_time = new Date(snapshotInfos[snapshotInfoIdx].created_at*1000)
      url = "#{Evercam.request.rootpath}/recordings/snapshots/#{moment.utc(date_time).toISOString()}"
      if history.replaceState
        window.history.replaceState({}, '', url);

saveImage = ->
  $('#save-recording-image').on 'click', ->
    date_time = new Date(snapshotInfos[snapshotInfoIdx].created_at*1000)
    SaveImage.save($("#imgPlayback").attr('src'), "#{Evercam.Camera.id}-#{getSnapshotDate(date_time).toISOString()}.jpg")

calculateWidth = ->
  tab_width = $("#recording-tab").width()
  if tab_width is 0
    tab_width = $(".tab-content").width()
  isChrome = !! navigator.userAgent.match(/Chrome/)
  left_col_width = tab_width - 231
  if isChrome
    left_col_width = tab_width - 235
  if tab_width > 480
    $("#recording-tab .left-column").css("width", "#{left_col_width}px")
    $("#recording-tab .right-column").css("width", "220px")
  else
    $("#recording-tab .left-column").css("width", "100%")
    $("#recording-tab .right-column").css("width", "100%")

handleResize = ->
  calculateWidth()
  $(window).resize ->
    calculateWidth()
    window.adjustScheduleCalendarWidth

window.initializeRecordingsTab = ->
  initDatePicker()
  handleSlider()
  handleWindowResize()
  handleBodyLoadContent()
  handleMinSecDropDown()
  handlePlay()
  handleTabOpen()
  fullscreenImage()
  saveImage()
  handleResize()
  window.initScheduleCalendar()
  window.setCloudRecordingToggle()
  window.handleShowScheduleClick()
