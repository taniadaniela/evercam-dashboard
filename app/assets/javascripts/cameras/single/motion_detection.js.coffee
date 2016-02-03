mdArea = null
mdInited = false
mdImage = undefined
MdChanged = false
method = "PATCH"
__imgHeight = 640
__imgWidth = 480
sensitivity_value = 0
fullWeekSchedule =
  "Monday": ["00:00-23:59"]
  "Tuesday": ["00:00-23:59"]
  "Wednesday": ["00:00-23:59"]
  "Thursday": ["00:00-23:59"]
  "Friday": ["00:00-23:59"]
  "Saturday": ["00:00-23:59"]
  "Sunday": ["00:00-23:59"]

sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = jQuery.ajax(settings)
  true

loadMotionImage = ->
  $('#refresh-motion').on 'click', ->
    img = mdImage
    live_snapshot_url = "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/recordings/snapshots/latest/jpg?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"
    src = "#{live_snapshot_url}&rand=" + new Date().getTime()
    img.attr 'src', src

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
    _defHeight = _renderedHeight - 5
    _defWidth =  _renderedWidth - 5
    renderedTopLeftX = Math.ceil(topLeftX / scaleX)
    renderedBottomRightX = Math.ceil(bottomRightX / scaleX)
    renderedTopLeftY = Math.ceil(topLeftY / scaleY)
    renderedBottomRightY = Math.ceil(bottomRightY / scaleY)
    if Evercam.Camera.motion.x1 && Evercam.Camera.motion.x2 && Evercam.Camera.motion.y1 && Evercam.Camera.motion.y2
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
        x1: 5
        y1: 5
        x2: _defWidth
        y2: _defHeight)
  mdArea = area.getSelection()
  mdInited = true

initMotionDetection = ->
  window.setTimeout mdShow, 100
  window.setTimeout mdInitArea, 100
  if Evercam.Camera.motion.enabled
    $("#enable-md").prop("checked", true)

initSlider = ->
  slidering = ''
  sensitivity_value = Evercam.Camera.motion.sensitivity
  slidering = $('#divSensitivity').slider
    value: sensitivity_value
    min: 0
    max: 20
    step: 1
    animate: true
  slidering.on "slide",(data) ->
    sensitivity_value = data.value

area_defined = ->
  return Evercam.Camera.motion.x1 > 0 || Evercam.Camera.motion.y1 > 0 || Evercam.Camera.motion.x2 > 0 || Evercam.Camera.motion.y2 > 0

handleTabOpen = ->
  $('.nav-tab-motion').on 'show.bs.tab', ->
    window.setTimeout mdShow, 100
    window.setTimeout mdInitArea, 100
  $('.nav-tab-motion').on 'hide.bs.tab', ->
    window.setTimeout mdHide, 100

addEmailToTable = ->
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
  if Evercam.Camera.motion.alert_interval_min isnt 0
    $("#reset-time").val(Evercam.Camera.motion.alert_interval_min)
  $("#alert-interval").text($("#reset-time").find(":selected").text())

FormatNumTo2 = (n) ->
  if n < 10
    return "0#{n}"
  else
    return n

extractImageResolution = ->
  img = new Image()
  img.src = mdImage.attr("src")
  img.onload = ->
    __imgWidth = @naturalWidth
    __imgHeight = @naturalHeight

saveMdSettings = ->
  $("#save-md-settings").on "click", ->
    data = {}
    data.enabled = $("#enable-md").is(":checked")
    data.sensitivity = sensitivity_value
    data.alert_interval_min = parseInt($("#reset-time").val())
    data.schedule = JSON.stringify(fullWeekSchedule)

    onError = (jqXHR, status, error) ->
      Notification.show 'Error updating settings.'
      false

    onSuccess = (result, status, jqXHR) ->
      Notification.show 'Motion detection settings updated.'
      method = 'PATCH'
      true

    settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      contentType: "application/x-www-form-urlencoded"
      type: method
      url: "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/apps/motion-detection?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"

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
    Notification.show 'Please select motion detection area.'
    return false

  data = {}
  data.x1 = actTopLeftX
  data.y1 = actTopLeftY
  data.x2 = actBottomRightX
  data.y2 = actBottomRightY

  onError = (jqXHR, status, error) ->
    Notification.show 'Failed to update motion detection area.'
    false

  onSuccess = (result, status, jqXHR) ->
    Notification.show 'Motion detection area saved.'
    method = 'PATCH'
    true

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    contentType: "application/x-www-form-urlencoded"
    type: method
    url: "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/apps/motion-detection?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"

  sendAJAXRequest(settings)

initNotification = ->
  Notification.init(".bb-alert");

isEmail = (email) ->
  regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/
  regex.test email

saveEmail = ->
  $("#save-email").on "click", ->
    if !isEmail $("#md-alert-email").val()
      Notification.show 'Please enter a valid email.'
    else
      data = {}
      data.email = $("#md-alert-email").val()

      onError = (jqXHR, status, error) ->
        Notification.show jqXHR.message
        false

      onSuccess = (result, status, jqXHR) ->
        $('#email-alert-settings-modal').modal('hide')
        parentdiv = $('<div>', {class: "email-box"})
        parentdiv.append($(document.createTextNode($("#md-alert-email").val())))
        parentdiv.append(' <i title="Remove" class="fa fa-trash-o font-size-17"></i>')
        $("#motion div#div-alert-emails").append(parentdiv)
        Notification.show 'Email saved for Motion detection alert.'
        $("#md-alert-email").val("")
        true

      settings =
        cache: false
        data: data
        dataType: 'json'
        error: onError
        success: onSuccess
        contentType: "application/x-www-form-urlencoded"
        type: 'POST'
        url: "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/apps/motion-detection/email?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"

      sendAJAXRequest(settings)

bindEmails = ->
  for email in Evercam.Camera.motion.emails
    parentdiv = $('<div>', {class: "email-box"})
    parentdiv.append($(document.createTextNode(email)))
    parentdiv.append(' <i title="Remove" class="fa fa-trash-o font-size-17"></i>')
    $("#div-alert-emails").append(parentdiv)
  true
  method = Evercam.Camera.motion.method if Evercam.Camera.motion.method

EmailAlertStatus = ->
  if !$("div#div-alert-emails").text()
    $("span#ec_cam_id").text('Off')
  else
    $("span#ec_cam_id").text('On')

deleteAddedEmail = ->
  $('#motion').on "click", ".fa-trash-o", ->
    parentsdiv = $(this).parent()
    data =
      camera_id: Evercam.Camera.id
      email: $(this).parent().text()

    onError = (jqXHR, status, error) ->
      Notification.show("Deletion of camera email failed. Please contact support.")
      false

    onSuccess = (data, status, jqXHR) ->
      parentsdiv.remove()
      EmailAlertStatus()
      Notification.show("Camera email deleted successfully.")
      true

    settings =
      ContentType: 'application/json'
      data: data
      dataType: 'text'
      error: onError
      success: onSuccess
      type: 'DELETE'
      url: "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/apps/motion-detection/email?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"

    sendAJAXRequest(settings)
    true

window.initializeMotionDetectionTab = ->
  if Evercam.Camera.motion.enabled is undefined
    return
  mdImage = $("#div-md-image img")
  extractImageResolution()
  initSlider()
  initMotionDetection()
  handleTabOpen()
  bindHours()
  saveMdSettings()
  initNotification()
  saveEmail()
  bindEmails()
  loadMotionImage()
  EmailAlertStatus()
  deleteAddedEmail()
