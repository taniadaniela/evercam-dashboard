mdArea = null
mdInited = false
mdImage = undefined
MdChanged = false
__imgHeight = 640
__imgWidth = 480
sensitivity_value = 0
days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']

sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = jQuery.ajax(settings)
  true

mdShow = ->
  mdImage.imgAreaSelect show: true

mdHide = ->
  mdImage.imgAreaSelect
    hide: true
    fadeSpeed: 0

mdSelected = (img, selection) ->
  MdChanged = true
  mdChanged()
  mdArea = selection

mdChanged = ->
  saveMdArea()

mdResetArea = ->
  area = mdImage.imgAreaSelect(
    instance: true
    handles: true
    onSelectEnd: mdSelected
    fadeSpeed: 200
    x1: mdArea.x1
    y1: mdArea.y1
    x2: mdArea.x2
    y2: mdArea.y2)
  mdArea = area.getSelection()

mdInitArea = ->
  #if MdChanged
  #  mdResetArea()
  #  return
  _originalHeight = __imgHeight
  _originalWidth = __imgWidth
  _renderedHeight = mdImage.height()
  _renderedWidth = mdImage.width()
  topLeftX = parseInt(Evercam.Camera.motion.x1)
  topLeftY = parseInt(Evercam.Camera.motion.y1)
  if Evercam.Camera.motion.x2 > _originalWidth
    bottomRightX = parseInt(_originalWidth)
  else
    bottomRightX = parseInt(Evercam.Camera.motion.x2)
  if Evercam.Camera.motion.y2 > _originalHeight
    bottomRightY = parseInt(_originalHeight)
  else
    bottomRightY = parseInt(Evercam.Camera.motion.y2)
  area = undefined
  if _renderedHeight == _originalHeight and _renderedWidth == _originalWidth
    if area_defined
      area = mdImage.imgAreaSelect(
        instance: true
        handles: true
        onSelectEnd: mdSelected
        fadeSpeed: 200
        x1: Evercam.Camera.motion.x1
        y1: Evercam.Camera.motion.y1
        x2: Evercam.Camera.motion.x2
        y2: Evercam.Camera.motion.y2)
    else
      area = mdImage.imgAreaSelect(
        instance: true
        handles: true
        onSelectEnd: mdSelected
        fadeSpeed: 200
        x1: 0
        y1: 0
        x2: _originalWidth
        y2: _originalHeight)
  else
    #calculate the size of the window here by scaling it down
    scaleX = _originalWidth / _renderedWidth
    scaleY = _originalHeight / _renderedHeight
    renderedTopLeftX = Math.ceil(topLeftX / scaleX)
    renderedBottomRightX = Math.ceil(bottomRightX / scaleX)
    renderedTopLeftY = Math.ceil(topLeftY / scaleY)
    renderedBottomRightY = Math.ceil(bottomRightY / scaleY)
    if true
      area = mdImage.imgAreaSelect(
        instance: true
        handles: true
        onSelectEnd: mdSelected
        fadeSpeed: 200
        x1: renderedTopLeftX
        y1: renderedTopLeftY
        x2: renderedBottomRightX
        y2: renderedBottomRightY)
    else
      area = mdImage.imgAreaSelect(
        instance: true
        handles: true
        onSelectEnd: mdSelected
        fadeSpeed: 200
        x1: 0
        y1: 0
        x2: _renderedWidth
        y2: _renderedHeight)
  mdArea = area.getSelection()
  mdInited = true

initMotionDetection = ->
  window.setTimeout mdShow, 100
  window.setTimeout mdInitArea, 100
  if Evercam.Camera.motion.enabled
    $("#enable-md").prop("checked", true)
    $("#enable-md-label span").addClass("checked")
    $("#md-enabled-span").text("On")
  else
    $("#md-enabled-span").text("Off")
  $("#alert-days").text(Evercam.Camera.motion.week_days)

initSlider = ->
  sensitivity_value = Evercam.Camera.motion.sensitivity
  $('#divSensitivity').slider
    min: 1
    max: 20
    step: 1
    animate: true
    value: Evercam.Camera.motion.sensitivity
    #create: saveMdSensitivity(3)
    change: (event, ui) ->
      sensitivity_value = ui.value

CheckAllWeek = ->
  $(".day-label-all").on "click", ->
    if $("#chkAll").is(':checked')
      $("input[name='day']").prop("checked", false)
      $(".day-label span").removeClass("checked")
    else
      $("input[name='day']").prop("checked", true)
      $(".day-label span").addClass("checked")

area_defined = ->
  return Evercam.Camera.motion.x1 > 0 || Evercam.Camera.motion.y1 > 0 || Evercam.Camera.motion.x2 > 0 || Evercam.Camera.motion.y2 > 0

handleTabOpen = ->
  $('.nav-tab-motion').on 'show.bs.tab', ->
    window.setTimeout mdShow, 100
    window.setTimeout mdInitArea, 100
  $('.nav-tab-motion').on 'hide.bs.tab', ->
    window.setTimeout mdHide, 100

addEmailToTable = ->
  $("#add-md-email").on "click", ->
    row_no = $(".email-box").length
    parentdiv = $('<div>', {class: "email-box"})
    parentdiv.attr("id", "email-box#{row_no}")
    removediv = $('<div>')
    removediv.addClass("col-lg-1 padding-left-0")
    removeicon = $('<i>')
    removeicon.addClass("fa fa-remove-sign remove-md-email")
    removeicon.attr("data-val", "#{row_no}")
    removediv.append(removeicon)
    emaildiv = $('<div>')
    emaildiv.addClass("col-lg-11 padding-left-0")
    emaildiv.append($(document.createTextNode($("#email").val())))
    clearfloatdiv = $('<div>', {class: "clear-f"})
    parentdiv.append(removediv)
    parentdiv.append(emaildiv)
    parentdiv.append(clearfloatdiv)
    $("#row-email-box").append(parentdiv)
    $("#email").val("")

removeEmail = ->
  $("#row-email-box").on "click", ".remove-md-email", ->
    row_no = $(this).attr("data-val")
    $("#email-box#{row_no}").remove()

bindHours = ->
  for num in [0..23]
    option = $('<option>').val(num).append(FormatNumTo2(num))
    $('#alert-from').append option
    option = $('<option>').val(num).append(FormatNumTo2(num))
    $('#alert-to').append option
  $('#alert-from').val(Evercam.Camera.motion.alert_from_hour)
  $('#alert-to').val(Evercam.Camera.motion.alert_to_hour)
  $("#reset-time").val(Evercam.Camera.motion.alert_interval_min)
  $("#alert-interval").text($("#reset-time").find(":selected").text())
  $("#alert-time").text("From #{Evercam.Camera.motion.alert_from_hour} to #{Evercam.Camera.motion.alert_to_hour} hour")

FormatNumTo2 = (n) ->
  if n < 10
    return "0#{n}"
  else
    return n

bindeDays = ->
  days = Evercam.Camera.motion.week_days.split(',')
  for day in days
    $("#chk#{day}").prop("checked", true)
    $("#lbl#{day} span").addClass("checked")

extractImageResolution = ->
  img = new Image()
  img.src = mdImage.attr("src")
  img.onload = ->
    __imgWidth = @naturalWidth
    __imgHeight = @naturalHeight

GetWeekdaysSelected = ->
  wDays = ''
  if $('#lblMon span').hasClass('checked')
    wDays += 'Mon,'
  if $('#lblTue span').hasClass('checked')
    wDays += 'Tue,'
  if $('#lblWed span').hasClass('checked')
    wDays += 'Wed,'
  if $('#lblThu span').hasClass('checked')
    wDays += 'Thu,'
  if $('#lblFri span').hasClass('checked')
    wDays += 'Fri,'
  if $('#lblSat span').hasClass('checked')
    wDays += 'Sat,'
  if $('#lblSun span').hasClass('checked')
    wDays += 'Sun,'
  if wDays.length > 0
    return wDays.substring(0, wDays.lastIndexOf(','))
  wDays

saveMdSettings = ->
  $("#save-md-settings").on "click", ->
    week_days = GetWeekdaysSelected()
    data = {}
    data.enabled = $("#enable-md").is(":checked")
    data.week_days = week_days
    data.alert_from_hour = parseInt($('#alert-from').val())
    data.alert_to_hour = parseInt($('#alert-to').val())
    data.alert_interval_min = parseInt($("#reset-time").val())
    data.sensitivity = sensitivity_value

    onError = (jqXHR, status, error) ->
      Notification.show 'Error to update motion detection settings.'
      false

    onSuccess = (result, status, jqXHR) ->
      $('#motion-detection-settings-modal').modal('hide')
      $("#alert-interval").text($("#reset-time").find(":selected").text())
      $("#alert-time").text("From #{$('#alert-from').val()} to #{$('#alert-to').val()} hour")
      $("#alert-days").text(week_days)
      if $("#enable-md-label span").hasClass("checked")
        $("#md-enabled-span").text("On")
      else
        $("#md-enabled-span").text("Off")
      Notification.show 'Motion detection settings updated.'
      true

    settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      contentType: "application/x-www-form-urlencoded"
      type: 'PATCH'
      url: "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/apps/motion-detection/settings?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"

    sendAJAXRequest(settings)

saveMdArea = ->
  if isNaN(mdArea.x1) or isNaN(mdArea.x2) or isNaN(mdArea.y1) or isNaN(mdArea.y2)
    Notification.show 'Motion detection area does not have valid values.'
    return false

  _originalHeight = __imgHeight
  _originalWidth = __imgWidth
  _renderedHeight = mdImage.height()
  _renderedWidth = mdImage.width()
  actTopLeftX = undefined
  actTopLeftY = undefined
  actBottomRightX = undefined
  actBottomRightY = undefined
  if _originalHeight == _renderedHeight and _originalWidth == _renderedWidth
    actTopLeftX = mdArea.x1
    actTopLeftY = mdArea.y1
    actBottomRightX = mdArea.x2
    actBottomRightY = mdArea.y2
  else
    scaleX = _originalWidth / _renderedWidth
    scaleY = _originalHeight / _renderedHeight
    actTopLeftX = Math.ceil(mdArea.x1 * scaleX)
    actBottomRightX = Math.ceil(mdArea.x2 * scaleX)
    actTopLeftY = Math.ceil(mdArea.y1 * scaleY)
    actBottomRightY = Math.ceil(mdArea.y2 * scaleY)
  if actTopLeftX == actBottomRightX and actTopLeftY == actBottomRightY
    Notification.show 'Plesae select motion detection area.'
    return false

  data = {}
  data.x1 = actTopLeftX
  data.y1 = actTopLeftY
  data.x2 = actBottomRightX
  data.y2 = actBottomRightY
  data.width = mdArea.width
  data.height = mdArea.height

  onError = (jqXHR, status, error) ->
    Notification.show 'Failed to update motion detection area.'
    false

  onSuccess = (result, status, jqXHR) ->
    Notification.show 'Motion detection area saved.'
    true

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    contentType: "application/x-www-form-urlencoded"
    type: 'PATCH'
    url: "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/apps/motion-detection/settings?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"

  sendAJAXRequest(settings)

initNotification = ->
  Notification.init(".bb-alert");

window.initializeMotionDetectionTab = ->
  mdImage = $("#div-md-image img")
  extractImageResolution()
  initSlider()
  initMotionDetection()
  handleTabOpen()
  CheckAllWeek()
  addEmailToTable()
  removeEmail()
  bindHours()
  bindeDays()
  saveMdSettings()
  initNotification()