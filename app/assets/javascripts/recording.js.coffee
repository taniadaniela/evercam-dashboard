apiUrl = 'https://api.evercam.io/v1/'
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

sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  jQuery.ajax(settings)
  true

initDatePicker = ->
  $("#ui_date_picker_inline").datepicker().on("changeDate", datePickerSelect).on "changeMonth", datePickerChange
  $("#ui_date_picker_inline table th[class*='prev']").bind "click", ->
    changeMonthFromArrow('p')

  $("#ui_date_picker_inline table th[class*='next']").bind "click", ->
    changeMonthFromArrow('n')
    return

  $("#hourCalandar td[class*='day']").bind "click", ->
    SetImageHour $(this).html(), "tdI" + $(this).html()
    return

  true

changeMonthFromArrow = (value) ->
  $("#ui_date_picker_inline").datepicker('fill');
  d = $("#ui_date_picker_inline").datepicker('getDate');
  day = d.getMonth()
  if value =='n'
    day = day + 2
  cameraId = $('#recording_tab_camera_id').val()
  api_id = $('#recording_tab_api_id').val()
  api_key = $('#recording_tab_api_key').val()

  data = {}
  data.api_id = api_id
  data.api_key = api_key
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
    url: apiUrl + 'cameras/' + cameraId+'/snapshots/'+ d.getFullYear() + "/" + day + '/days.json'

  sendAJAXRequest(settings)
  if value =='n'
    d.setMonth(d.getMonth()+1)
  else if value =='p'
    d.setMonth(d.getMonth()-1)
  $("#ui_date_picker_inline").datepicker('setDate',d);
  snapshotInfos = null
  snapshotInfoIdx = 1
  currentFrameNumber = 0
  true

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
  true

datePickerChange=(value)->
  d = value.date
  cameraId = $('#recording_tab_camera_id').val()
  api_id = $('#recording_tab_api_id').val()
  api_key = $('#recording_tab_api_key').val()

  data = {}
  data.api_id = api_id
  data.api_key = api_key
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
    url: apiUrl + 'cameras/' + cameraId+'/snapshots/'+ d.getFullYear() + "/" + (d.getMonth() + 1) + '/days.json'

  sendAJAXRequest(settings)
  snapshotInfos = null
  snapshotInfoIdx = 1
  currentFrameNumber = 0
  true

clearHourCalander = ->
  $("#hourCalandar td[class*='day']").removeClass("active")
  calDays = $("#hourCalandar td[class*='day']")
  calDays.each(->
    calDay = $(this)
    calDay.css("color": "#c5c5c5", "font-family":"proxima-nova-regular", "font-weight":"normal" )
  )
  true

ResetDays = ->
  clearTimeout ClearCalanderTimeOut
  return  unless BoldDays?
  calDays = $("#ui_date_picker_inline table td[class*='day']")
  calDays.each (idx, el) ->
    calDay = $(this)
    iDay = parseInt(calDay.text())

    j = 0

    while j < BoldDays.length
      if BoldDays[j] is iDay
        calDay.css "color": "#428bca","font-weight": "bold", "font-family":"proxima-nova-bold"
        break
      j++
    return
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
    $("#divPopup").html("Frame " + frameNo + ", " + shortDate(new Date(snapshotInfos[idx].created_at*1000)) + motionVal)
    $("#divPopup").show()
    $("#divPopup").offset({ top: ev.pageY + 20, left: x })

    $("#divSlider").css('background-position', (ev.pageX - sliderStartX) + 'px 0px')
    $("#divPointer").css('background-position', (ev.pageX - sliderStartX) + 'px 0px')
    true

  $("#divSlider").mousemove(onSliderMouseMove)

  onSliderMouseOut = ->
    $("#divPopup").hide()
    $("#divSlider").css('background-position', '-3px 0px')
    $("#divPointer").css('background-position', '-3px 0px')
    true

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
    true

  $("#divSlider").click(onSliderClick)

  true

showLoader = ->
  $("#imgLoaderRec").width($('#imgPlayback').width())
  $("#imgLoaderRec").height($('#imgPlayback').height())
  $("#imgLoaderRec").css("top", $('#imgPlayback').css('top'))
  $("#imgLoaderRec").css("left", $('#imgPlayback').css('left'))
  $("#imgLoaderRec").show()
  true

SetInfoMessage = (currFrame, dt) ->
  $("#divInfo").fadeIn()
  $("#divInfo").html("<b>Frame " + currFrame + " of " + totalSnaps + "</b> " + dt + " ")
  totalWidth = $("#divSlider").width()
  $("#divPointer").width(totalWidth * currFrame / totalFrames)
  true

UpdateSnapshotRec = (snapInfo) ->
  showLoader()
  SetInfoMessage currentFrameNumber, shortDate(new Date(snapInfo.created_at*1000))
  loadImage(snapInfo.created_at)
  true

ChangeFormatAndGetFormatted = (str) ->
  dtAr = str.split("/")
  dt = new Date(dtAr[1] + "/" + dtAr[0] + "/" + dtAr[2])
  DateToFormattedStr dt
  true

handleBodyLoadContent = ->
  offset = $('#camera_time_offset').val()
  CameraOffset = parseInt(offset)/3600
  currentDate = getLocationBaseDateTime(offset)
  cameraCurrentHour = currentDate.getHours()

  $("#hourCalandar td[class*='day']").removeClass("active")
  $("#tdI" + cameraCurrentHour + " a").addClass("active")
  PreviousImageHour = "tdI" + cameraCurrentHour;

  $("#ui_date_picker_inline").datepicker('setDate', currentDate)
  showLoader()
  HighlightCurrentMonth()
  BoldSnapshotHour(false)
  true

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
  cameraId = $('#recording_tab_camera_id').val()
  api_id = $('#recording_tab_api_id').val()
  api_key = $('#recording_tab_api_key').val()

  data = {}
  data.api_id = api_id
  data.api_key = api_key
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
    url: apiUrl + 'cameras/' + cameraId+'/snapshots/'+ d.getFullYear() + "/" + (d.getMonth() + 1) + '/days.json'

  sendAJAXRequest(settings)
  true

HighlightCurrentMonthSuccess = (results, status, jqXHR) ->
  calDays = $("#ui_date_picker_inline table td[class*='day']")
  BoldDays = results.days
  calDays.each(->
    calDay = $(this)
    iDay = parseInt(calDay.text())

    for result in results.days
      if result == iDay
        calDay.css("color": "#428bca","font-weight": "bold", "font-family":"proxima-nova-bold")
        break
  )
  true

BoldSnapshotHour = (callFromDt) ->
  $("#divDisableButtons").removeClass("hide").addClass("show")
  $("#divFrameMode").removeClass("show").addClass("hide")
  $("#divPlayMode").removeClass("show").addClass("hide")
  d = $("#ui_date_picker_inline").datepicker('getDate');
  cameraId = $('#recording_tab_camera_id').val()
  api_id = $('#recording_tab_api_id').val()
  api_key = $('#recording_tab_api_key').val()

  data = {}
  data.api_id = api_id
  data.api_key = api_key
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
    url: apiUrl + 'cameras/' + cameraId+'/snapshots/'+ d.getFullYear() + "/" + (d.getMonth() + 1) + '/' + d.getDate()+ '/hours.json'

  sendAJAXRequest(settings)
  true

BoldSnapshotHourSuccess = (result, context) ->
  lastBoldHour = 0;
  hasRecords = false;
  for hour in result.hours
    hr = hour + CameraOffset
    $("#tdI"+hr).css("color": "#428bca","font-weight": "bold", "font-family":"proxima-nova-bold");
    lastBoldHour = hr
    hasRecords = true

  if hasRecords
    if this.isCall
      GetCameraInfo true
    else
      SetImageHour(lastBoldHour, "tdI" + lastBoldHour)
  else
    NoRecordingDayOrHour()
  true

GetCameraInfo = (isShowLoader) ->
  $("#divDisableButtons").removeClass("hide").addClass("show")
  $("#divFrameMode").removeClass("show").addClass("hide")
  $("#divPlayMode").removeClass("show").addClass("hide")
  if isShowLoader
    showLoader()
  fromDT = GetFromDT()/1000
  toDT = GetToDT()/1000

  cameraId = $('#recording_tab_camera_id').val()
  api_id = $('#recording_tab_api_id').val()
  api_key = $('#recording_tab_api_key').val()

  data = {}
  data.from = fromDT
  data.to = toDT
  data.limit = limit
  data.page = 1
  data.api_id = api_id
  data.api_key = api_key
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
      $("#divSlider").width(sliderpercentage + "%")
      currentFrameNumber=1

      SetInfoMessage(currentFrameNumber, shortDate(new Date(snapshotInfos[snapshotInfoIdx].created_at*1000)))
      loadImage(snapshotInfos[snapshotInfoIdx].created_at)
    true

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    contentType: "application/json; charset=utf-8"
    type: 'GET'
    url: apiUrl + 'cameras/' + cameraId+'/snapshots/range.json'

  sendAJAXRequest(settings)
  true

loadImage = (timestamp) ->
  cameraId = $('#recording_tab_camera_id').val()
  api_id = $('#recording_tab_api_id').val()
  api_key = $('#recording_tab_api_key').val()

  data = {}
  data.with_data = true
  data.range = 1
  data.api_id = api_id
  data.api_key = api_key

  onError = (jqXHR, status, error) ->
    false

  onSuccess = (response) ->
    if response.snapshots.length > 0
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
    url: apiUrl + 'cameras/' + cameraId+'/snapshots/'+timestamp+'.json'

  sendAJAXRequest(settings)
  true

shortDate = (date) ->
  hour = parseInt(cameraCurrentHour)
  return FormatNumTo2(date.getDate())+'/'+FormatNumTo2(date.getMonth()+1)+'/'+date.getFullYear()+' '+FormatNumTo2(hour)+':'+FormatNumTo2(date.getMinutes())+':'+FormatNumTo2(date.getSeconds())

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

DateToFormattedStr = (d) ->
  if d == null then return ""
  year = d.getFullYear()
  month = d.getMonth() + 1
  day = d.getDate()
  hour = d.getHours()
  minute = d.getMinutes()
  second = d.getSeconds()
  miliseconds = d.getMilliseconds() + ""

  if miliseconds.length == 2
    miliseconds = '0' + miliseconds
  else if miliseconds.length == 1
    miliseconds = '00' + miliseconds
  else if miliseconds.length == 0 || miliseconds == 0
    miliseconds = ''
  return "" + FormatNumTo2(year) + FormatNumTo2(month) + FormatNumTo2(day) + FormatNumTo2(hour) + FormatNumTo2(minute) + FormatNumTo2(second) + miliseconds

FormatNumTo2 = (n) ->
  if n < 10
    return "0" + n
  else
    return n

NoRecordingDayOrHour = ->
  $("#divRecent").show()
  $("#imgPlayback").attr("src", "/assets/norecordings.gif")
  $("#divInfo").fadeOut()
  $("#divPointer").width(0)
  $("#divSliderBackground").width(0)

  $("#MDSliderItem").html("")
  $("#divNoMd").show()
  $("#divNoMd").text('No motion detected')
  HideLoader()

  totalFrames = 0;
  true

SetImageHour = (hr, id) ->
  value = $("#" + id).html()
  $("#ddlRecMinutes").val(0)
  $("#ddlRecSeconds").val(0)
  cameraCurrentHour = hr
  $("#" + PreviousImageHour).removeClass("active")
  $("#" + id).addClass("active")
  PreviousImageHour = id
  snapshotInfos = null
  Pause()
  currentFrameNumber = 0
  $("#divPointer").width(0)
  $("#divSlider").width("0%")
  $("#divDisableButtons").removeClass("hide").addClass("show")
  $("#divFrameMode").removeClass("show").addClass("hide")
  $("#divPlayMode").removeClass("show").addClass("hide")

  if $("#" + id).css('font-weight') == '700' || $("#" + id).css('font-weight') =='bold'
    $("#divSliderBackground").width("100%")
    $("#divSliderMD").width("100%")
    $("#MDSliderItem").html("")
    $("#divNoMd").show()
    $("#btnCreateHourMovie").removeAttr('disabled')
    GetCameraInfo true
  else
    $("#divRecent").show()
    $("#divInfo").fadeOut()
    $("#divSliderBackground").width("0%")
    $("#txtCurrentUrl").val("")
    $("#divSliderMD").width("100%")
    $("#MDSliderItem").html("")
    $("#btnCreateHourMovie").attr('disabled', true)
    totalFrames = 0
    $("#imgPlayback").attr("src", "/assets/norecordings.gif")
    $("#divNoMd").show()
    $("#divNoMd").text('No motion detected')
    HideLoader()
  true

Pause = ->
  isPlaying = false
  $("#divFrameMode").removeClass("hide").addClass("show")
  $("#divPlayMode").removeClass("show").addClass("hide")
  PauseAfterPlay = true
  true

HideLoader = ->
  $("#imgLoaderRec").hide();
  true

handleWindowResize = ->
  $(window).bind "resize", ->
    totalWidth = $("#divSlider").width()
    $("#divPointer").width(totalWidth * currentFrameNumber / totalFrames)
  true

handlePlay = ->
  $("#btnPlayRec").bind "click", ->
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
    return

  $("#btnPauseRec").bind "click", ->
    Pause()
    return

  $("#btnFRwd").bind "click", ->
    SetPlaySpeed 10, -1
    return

  $("#btnRwd").bind "click", ->
    SetPlaySpeed 5, -1
    return

  $("#btnFFwd").bind "click", ->
    SetPlaySpeed 10, 1
    return

  $("#btnFwd").bind "click", ->
    SetPlaySpeed 5, 1
    return

  $(".skipframe").bind "click", ->
    if $(this).html() is "+Frame"
      SetSkipFrames 1, "n"
    else if $(this).html() is "+5"
      SetSkipFrames 5, "n"
    else if $(this).html() is "+10"
      SetSkipFrames 10, "n"
    else if $(this).html() is "+100"
      SetSkipFrames 100, "n"
    else if $(this).html() is "-Frame"
      SetSkipFrames 1, "p"
    else if $(this).html() is "-5"
      SetSkipFrames 5, "p"
    else if $(this).html() is "-10"
      SetSkipFrames 10, "p"
    else SetSkipFrames 100, "p"  if $(this).html() is "-100"
    return

  return

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
  return

DoNextImg = ->
  return  if totalFrames is 0
  if snapshotInfos.length is snapshotInfoIdx
    Pause()
    currentFrameNumber = snapshotInfos.length
    snapshotInfoIdx = snapshotInfos.length - 1
    return
  si = snapshotInfos[snapshotInfoIdx]
  cameraId = $('#recording_tab_camera_id').val()
  api_id = $('#recording_tab_api_id').val()
  api_key = $('#recording_tab_api_key').val()

  data = {}
  data.with_data = true
  data.range = 1
  data.api_id = api_id
  data.api_key = api_key

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
      SetInfoMessage currentFrameNumber, shortDate(new Date(si.created_at*1000))
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

    true

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    contentType: "application/json; charset=utf-8"
    type: 'GET'
    url: apiUrl + 'cameras/' + cameraId+'/snapshots/'+si.created_at+'.json'

  sendAJAXRequest(settings)
  return

SetPlayFromImage = (playFromIndex) ->
  #set play from image
  if playFromTime isnt "" and isFoundPlayFrom
    if playFromTime.length is 14
      SelectSliderWithoutMilisec playFromTime
    else
      SelectSlider playFromTime
  else if playFromTime isnt "" and isFoundPlayFrom
    if playFromTime.length is 14
      SelectSliderWithoutMilisec playFromTime
    else
      SelectSlider playFromTime
  return

SelectSlider = (fDt) ->
  i = 0

  while i < snapshotInfos.length
    si = snapshotInfos[i]
    frameDt = ChangeFormatAndGetFormatted(snapshotInfos[i].date)
    if frameDt is fDt
      currentFrameNumber = i + 1
      snapshotInfoIdx = i
      showLoader()
      $("#img").attr "src", si.url
      $("#hiddenimg").attr "src", si.url
      SetInfoMessage1 currentFrameNumber, si.date, frameDt
      HideLoader()
      isFoundPlayFrom = false
      return
    i++
  return

SelectSliderWithoutMilisec = (fDt) ->
  i = 0

  while i < snapshotInfos.length
    si = snapshotInfos[i]
    if si.FDT is changedPlayFrom
      currentFrameNumber = i + 1
      snapshotInfoIdx = i
      showLoader()
      $("#img").attr "src", si.Url
      $("#hiddenimg").attr "src", si.Url
      SetInfoMessage1 currentFrameNumber, si.DT, si.FDT
      HideLoader()
      isFoundPlayFrom = false
      return
    i++
  return

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
          return
        else if sDt[2] > sec
          currentFrameNumber = i
          snapshotInfoIdx = i - 1
          si = snapshotInfos[snapshotInfoIdx]
          sDt = si.date.substring(si.date.indexOf(" ") + 1).split(":")
          $("#ddlRecSeconds").val sDt[2]
          UpdateSnapshotRec si
          return
      else if sDt[1] > min
        currentFrameNumber = i
        snapshotInfoIdx = i - 1
        si = snapshotInfos[snapshotInfoIdx]
        sDt = si.date.substring(si.date.indexOf(" ") + 1).split(":")
        $("#ddlRecSeconds").val sDt[2]
        UpdateSnapshotRec si
        return
      i++
  else
    currentFrameNumber = snapshotInfos.length + 1
    snapshotInfoIdx = snapshotInfos.length

    UpdateSnapshotRec snapshotInfos[snapshotInfoIdx]
  return

handleMinSecDropDown = ->
  hour = 1

  while hour <= 59
    option = $("<option>").val(FormatNumTo2(hour)).append(FormatNumTo2(hour))
    $("#ddlRecMinutes").append option
    option = $("<option>").val(FormatNumTo2(hour)).append(FormatNumTo2(hour))
    $("#ddlRecSeconds").append option
    hour++
  $("#ddlRecMinutes").bind "change", ->
    SelectImagesByMinSec()
    return

  $("#ddlRecSeconds").bind "change", ->
    SelectImagesByMinSec()
    return

  return

handleTabEvent = ->
  $("a[data-toggle=\"tab\"]").bind "click", ->
    tabName = $(this).html()
    if tabName is "Snapshots"
      GetCameraInfo false

  true

initializeRecordingsTab = ->
  initDatePicker()
  handleSlider()
  handleWindowResize()
  handleBodyLoadContent()
  handleMinSecDropDown()
  handlePlay()
  handleTabEvent()
  true

if !window.Evercam
  window.Evercam = {}

window.Evercam.Recordings =
  initializeTab: initializeRecordingsTab