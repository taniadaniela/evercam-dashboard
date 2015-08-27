mdArea = null
mdInited = false
mdImage = undefined
MdChanged = false
__imgHeight = 640
__imgWidth = 480
days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']

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
  #$('#btnMdSave').attr 'disabled', false
  #$('#btnMdSave').val ' Save '
  #$('#btnMdSave').removeClass('btnstyle-disabled').addClass 'btnstyle'
  return

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
  topLeftX = parseInt(0)
  topLeftY = parseInt(0)
  bottomRightX = parseInt(100)
  bottomRightY = parseInt(100)
  _originalHeight = __imgHeight
  _originalWidth = __imgWidth
  _renderedHeight = mdImage.height()
  _renderedWidth = mdImage.width()
  area = undefined
  if _renderedHeight == _originalHeight and _renderedWidth == _originalWidth
    if true
      area = mdImage.imgAreaSelect(
        instance: true
        handles: true
        onSelectEnd: mdSelected
        fadeSpeed: 200
        x1: 0
        y1: 0
        x2: 100
        y2: 100)
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

initSlider = ->
  $('#divSensitivity').slider
    min: 1
    max: 5
    step: 1
    animate: true
    value: 2
    #create: saveMdSensitivity(3)
    #change: (event, ui) ->
      #saveMdSensitivity ui.value

CheckAllWeek = ->
  $(".day-label-all").on "click", ->
    if $("#chkAll").is(':checked')
      $("input[name='day']").prop("checked", false)
      $(".day-label span").removeClass("checked")
    else
      $("input[name='day']").prop("checked", true)
      $(".day-label span").addClass("checked")

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
    option = $('<option>').val(FormatNumTo2(num)).append(FormatNumTo2(num))
    $('#alert-from').append option
    option = $('<option>').val(FormatNumTo2(num)).append(FormatNumTo2(num))
    $('#alert-to').append option

FormatNumTo2 = (n) ->
  if n < 10
    return "0#{n}"
  else
    return n

window.initializeMotionDetectionTab = ->
  mdImage = $("#div-md-image img")
  initSlider()
  initMotionDetection()
  handleTabOpen()
  CheckAllWeek()
  addEmailToTable()
  removeEmail()
  bindHours()