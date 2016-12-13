#= require responsiveslides.js
#= require detect_timezone.js

unselect_all = false
camera_select = null
appApiUrl = "http://snapmail.evercam.io/api/snapmails"

initNotification = ->
  Notification.init(".bb-alert")

window.sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = $.ajax(settings)

loadSnapmails = ->
  onError = (jqXHR, status, error) ->
    $(".bb-alert").removeClass("alert-info").addClass("alert-danger")
    Notification.show("Failed to retrive snapmails.")

  onSuccess = (snapMails, status, jqXHR) ->
    $('#divSnapmails').html()
    $.each snapMails, (index, snapmail) ->
      $('#divSnapmails').append getSnapmailHtml(snapmail, index)
      initPopup(snapmail.key)
    $(".rslides").responsiveSlides({
      auto: true,
      pager: true,
      nav: false,
      pause: true,
      speed: 500,
      namespace: "centered-btns"
    })

  settings =
    cache: false
    data: {}
    dataType: 'json'
    error: onError
    success: onSuccess
    type: 'GET'
    url: "#{appApiUrl}/users/#{Evercam.User.username}"

  sendAJAXRequest(settings)

getSnapmailHtml = (snapMail, index) ->
  cameras = snapMail.cameras.split(',')
  html = '<div id="dataslot' + snapMail.key + '" class="list-border margin-bottom10">'
  html += '    <div class="col-md-4" style="min-height:0px;">'
  html += '    <div class="card" style="min-height:0px;">'
  html += '        <div class="snapstack-loading" id="snaps-' + snapMail.key + '" >'
  html += '           <ul class="rslides" id="snapmail' + index + '">'
  $.each cameras, (i, camera) ->
    thumbnail_url = "https://media.evercam.io/v1/cameras/#{camera}/thumbnail?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}";
    html += '           <li><img src="' + thumbnail_url + '" class="stackimage" style="visibility: visible" id="stackimage-' + snapMail.key + '-' + camera + '" alt="' + snapMail.camera_names.split(',')[i] + '" ><p>' + snapMail.camera_names.split(',')[i] + '</p></li>'
  html += '           </ul>'
  html += '        </div>'
  html += '        <input type="hidden" id="txtCamerasId' + snapMail.key + '" value="' + snapMail.cameras + '" /><input type="hidden" id="txtRecipient' + snapMail.key + '" value="' + (if snapMail.recipients is null then '' else snapMail.recipients) + '" /><input type="hidden" id="txtTime' + snapMail.key + '" value="' + snapMail.notify_time + '" />'
  html += '        <input type="hidden" id="txtDays' + snapMail.key + '" value="' + snapMail.notify_days + '" /><input type="hidden" id="txtUserId' + snapMail.key + '" value="' + snapMail.user_id + '" /><input type="hidden" id="txtTimezone' + snapMail.key + '" value="' + snapMail.timezone + '" />'
  html += '        <div class="hash-label"><a data-toggle="modal" data-target="#snapmail-form" class="tools-link edit-snapmail" data-val="' + snapMail.key + '" data-action="e"><div class="camera-name">' + snapMail.camera_names + '</div></a></div>'
  html +='         <div class="camera-time"><span class="spn-label">@</span><div class="div-snapmail-values">' + snapMail.notify_time + ' (' + snapMail.timezone + ')</div><div class="clear-f"></div></div>'
  html +='         <div class="camera-days"><span class="spn-label">on</span><div class="div-snapmail-values">' + snapMail.notify_days.replace(/,/g, ' ') + ' </div><div class="clear-f"></div></div>'
  html +='         <div class="camera-email"><span class="spn-label">sent to</span><div class="div-snapmail-values">' + makeMailTo(snapMail.recipients) + '</div><div class="clear-f"></div></div>'

  html += '    </div>'
  html += '    <div class="" style="min-height:0px;">'
  html += '        <div class="text-right delete-snapmail">'
  html += '             <span id=pop-' + snapMail.key + ' class="popbox2"><div id="open-' + snapMail.key + '" href="javascript:;" class="tools-link open2" data-val="' + snapMail.key + '"><div class="icon-button red"><i class="icon-trash plus-btn"></i><paper-ripple class="circle recenteringTouch" fit></paper-ripple></div></div>'
  html += '             <div class="collapse-popup">'
  html += '               <div class="box-snapmail" id="box-' + snapMail.key + '" style="width:288px;">'
  html += '                   <div class="arrow2" id="arrow-' + snapMail.key + '"></div>'
  html += '                   <div class="arrow-border2" id="arrow-border-' + snapMail.key + '"></div>'
  html += '                   <div class="margin-bottom-10">Are you sure?</div>'
  html += '                   <div class="margin-bottom-10"><input class="btn btn-primary delete-btn delete-share" type="button" value="Yes, Remove" data-val="' + snapMail.key + '"/><div href="#" id="close-popup-' + snapMail.key + '" class="btn closepopup2 grey" fit><div class="text-center">Cancel</div></div></div>'
  html += '               </div>'
  html += '             </div></span>'
  html += '       </div>'
  html += '       </div>'
  html += '    </div>'
  html += '</div>'
  html

makeMailTo = (emails) ->
  if emails is null
    return ''
  arEmails = emails.split(',')
  strEmails = ''
  i = 0
  while i < arEmails.length
    strEmails += arEmails[i] + ', '
    #'<a href="mailto:' + arEmails[i] + ';">' + arEmails[i] + '</a>, '
    i++
  strEmails.substring 0, strEmails.lastIndexOf(',')

initPopup = (key) ->
  $("#pop-#{key}").popbox
    open: "#open-#{key}"
    box: "#box-#{key}"
    arrow: "#arrow-#{key}"
    arrow_border: "#arrow-border-#{key}"
    close: "#close-popup-#{key}"

initCameraSelect = ->
  camera_select = $('#ddlCameras').select2
    placeholder: 'Select Camera',
    allowClear: true,
    templateSelection: format,
    templateResult: format
    escapeMarkup: (m) ->
      m

format = (state) ->
  is_offline = ""
  if !state.id
    return state.text
  if state.id == '0'
    return state.text
  if state.element.className is "onlinec"
    is_offline = '<i class="red main-sidebar fa fa-chain-broken"></i>'
  return $("<span><img style='height:30px;margin-bottom:1px;margin-top:1px;width:35px;' src='#{state.element.attributes[1].value}' class='img-flag' />&nbsp;#{state.text}</span>&nbsp;#{is_offline}")

initInputTags = ->
  $("#txtRecipient").tagsInput
    'height': 'auto'
    'width': 'auto'
    'defaultText': 'Add Recipients'
    'onAddTag': (email) ->
      if !validateEmailByVal(email)
        $(".bb-alert").removeClass("alert-info").addClass("alert-danger")
        Notification.show 'Invalid recipient email.'
      return
    'onRemoveTag': (email) ->
      return
    'delimiter': [
      ','
      ';'
    ]
    'removeWithBackspace': true
    'minChars': 0
    'maxChars': 0
    'placeholderColor': '#666666'

validateEmailByVal = (email) ->
  reg = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/
  addresstrimed = email.replace(RegExp(' ', 'gi'), '')
  if reg.test(addresstrimed) == false
    false
  else
    true

initTimepicker = ->
  $('.timepicker-default').timepicker
    minuteStep: 5
    showSeconds: false
    showMeridian: false

handleDayCheckBox = ->
  tz_info = jzTimezoneDetector.determine_timezone()
  $('#ddlTimezone').val GetUtcZoneValue(tz_info.key)

saveSnapmail = ->
  $('#add-snapmail').on 'click', ->
    save_button = $(this)
    $(".bb-alert").removeClass("alert-info").addClass("alert-danger")
    cameraIds = ''
    cameraNames = ''
    $('#ddlCameras :selected').each (i, selected) ->
      cameraIds += $(selected).val() + ','
      cameraNames += $(selected).text() + ', '
    if cameraIds is ''
      Notification.show 'Please select camera(s) to continue.'
    cameraIds = cameraIds.substring(0, cameraIds.lastIndexOf(','))
    cameraNames = cameraNames.substring(0, cameraNames.lastIndexOf(','))
    if $('#txtRecipient').val() != ''
      emails = $('#txtRecipient').val().split(',')
      i = 0
      while i < emails.length
        if !validateEmailByVal(emails[i])
          Notification.show 'Invalid email \'' + emails[i] + '\'.'
          return
        i++
    else
      if $('#txtkey').val() == ''
        Notification.show 'Please enter recipients to continue.'
        return
    if $('#txtTime').val() == ''
      Notification.show 'Please select time to continue.'
      return
    if $('#ddlTimezone').val() == '0'
      Notification.show 'Please select timezone to continue.'
      return
    if GetWeekdaysSelected() == ''
      Notification.show 'Please select day(s) to continue.'
      return

    o =
      'user_id': Evercam.User.username
      'user_name': Evercam.User.fullname
      'cameras': cameraIds
      'camera_names': cameraNames
      'recipients': $('#txtRecipient').val()
      'notify_days': GetWeekdaysSelected()
      'notify_time': $('#txtTime').val()
      'timezone': $('#ddlTimezone').val()
      'is_active': true
      'access_token': "#{Evercam.User.api_id}:#{Evercam.User.api_key}"
    action = 'POST'
    queryString = ''
    if $('#txtkey').val() != ''
      action = 'PUT'
      queryString = '/' + $('#txtkey').val()
    save_button.attr 'disabled', true

    onError = (jqXHR, status, error) ->
      save_button.removeAttr('disabled')
      Notification.show('Error: ' + response.responseJSON.ExceptionMessage)

    onSuccess = (snapMail, status, jqXHR) ->
      $(".bb-alert").removeClass("alert-danger").addClass("alert-info")
      save_button.removeAttr('disabled')
      if $('#txtkey').val() != ''
        $("#dataslot#{snapMail.key}").remove()
        index = $("#divSnapmails").children("#dataslot#{snapMail.key}").index()
      else
        index = $("#divSnapmails div.card").length
      $('#divSnapmails').prepend getSnapmailHtml(snapMail, index)
      initPopup(snapMail.key)
      $("#snapmail-form").modal("hide")
      clearForm()

    settings =
      cache: false
      data: o
      dataType: 'json'
      ContentType: 'application/x-www-form-urlencoded'
      error: onError
      success: onSuccess
      type: action
      url: appApiUrl + queryString

    sendAJAXRequest(settings)

GetWeekdaysSelected = ->
  wDays = ''
  $.each($("input[class='days']:checked"), ->
    wDays += "#{$(this).val()},"
  )
  if wDays.length > 0
    return wDays.substring(0, wDays.lastIndexOf(','))
  wDays

clearForm = ->
  $('.formButtonCancel').click()
  $('.modal-header h3').html 'New SnapMail'
  $('#txtkey').val ''
  $('#txtRecipient').val ''
  tz_info = jzTimezoneDetector.determine_timezone()
  $('#ddlTimezone').val GetUtcZoneValue(tz_info.key)
  d = new Date
  $('#txtTime').val FormatNumTo2(d.getHours()) + ':' + FormatNumTo2(d.getMinutes())
  $('#divAlert').slideUp()
  $('.select2-search-choice').remove()
  $('span.tag').remove()
  $.fn.select2.defaults.reset()
  $('#ddlCameras :selected').each (i, selected) ->
    $(selected).removeAttr 'selected'
  camera_select.val(null).trigger("change")
  $('#uniform-chkMon .icheckbox_flat-blue').removeClass 'checked'
  $("#chkMon").prop("checked", false)
  $('#uniform-chkTue .icheckbox_flat-blue').removeClass 'checked'
  $('#chkTue').prop 'checked', false
  $('#uniform-chkWed .icheckbox_flat-blue').removeClass 'checked'
  $('#chkWed').prop 'checked', false
  $('#uniform-chkThu .icheckbox_flat-blue').removeClass 'checked'
  $('#chkThu').prop 'checked', false
  $('#uniform-chkFri .icheckbox_flat-blue').removeClass 'checked'
  $('#chkFri').prop 'checked', false
  $('#uniform-chkSat .icheckbox_flat-blue').removeClass 'checked'
  $('#chkSat').prop 'checked', false
  $('#uniform-chkSun .icheckbox_flat-blue').removeClass 'checked'
  $('#chkSun').prop 'checked', false
  $('#uniform-chkAllDay .icheckbox_flat-blue').removeClass 'checked'
  $('#chkAllDay').prop 'checked', false

FormatNumTo2 = (n) ->
  if n < 10
    "0#{n}"
  else
    n

EditSnapmail = ->
  $("#divSnapmails").on "click", ".edit-snapmail", ->
    key = $(this).attr("data-val")
    $('#s2id_ddlCameras').hide()
    $('#txtkey').val key
    $('.caption').html 'Edit SnapMail'
    $('#ddlTimezone').val $('#txtTimezone' + key).val()
    emails = $('#txtRecipient' + key).val()
    if emails != null or emails != ''
      arEmails = emails.split(',')
      $.each arEmails, (i, email) ->
        if email != ''
          $('#txtRecipient').addTag email
    days = $('#txtDays' + key).val().split(',')
    i = 0
    $.each days, (i, day) ->
      switch day
        when 'Mon'
          $('#uniform-chkMon .icheckbox_flat-blue').addClass 'checked'
          $('#chkMon').prop 'checked', true
        when 'Tue'
          $('#uniform-chkTue .icheckbox_flat-blue').addClass 'checked'
          $('#chkTue').prop 'checked', true
        when 'Wed'
          $('#uniform-chkWed .icheckbox_flat-blue').addClass 'checked'
          $('#chkWed').prop 'checked', true
        when 'Thu'
          $('#uniform-chkThu .icheckbox_flat-blue').addClass 'checked'
          $('#chkThu').prop 'checked', true
        when 'Fri'
          $('#uniform-chkFri .icheckbox_flat-blue').addClass 'checked'
          $('#chkFri').prop 'checked', true
        when 'Sat'
          $('#uniform-chkSat .icheckbox_flat-blue').addClass 'checked'
          $('#chkSat').prop 'checked', true
        when 'Sun'
          $('#uniform-chkSun .icheckbox_flat-blue').addClass 'checked'
          $('#chkSun').prop 'checked', true
    all_selected()
    cameraIds = $('#txtCamerasId' + key).val().split(',')
    camera_select.val(cameraIds).trigger("change")
    $('#txtTime').val $('#txtTime' + key).val()
    $('#s2id_ddlCameras').show()

handleModelEvents = ->
  $("#snapmail-form").on "hide.bs.modal", ->
    clearForm()

RemoveSnapmail = (key) ->
  $("#divSnapmails").on "click", ".delete-share", ->
    key = $(this).attr("data-val")
    $('#dataslot' + key).fadeOut 500, ->
      onError = (jqXHR, status, error) ->
        $('#dataslot' + key).fadeIn 1000
        Notification.show('Error: ' + response.responseJSON.ExceptionMessage)

      onSuccess = (snapMail, status, jqXHR) ->
        $('#dataslot' + key).remove()
        if $("#divSnapmails div").length is 0
          $("#divLoadingApps").show()

      settings =
        cache: false
        data: {}
        dataType: 'json'
        ContentType: 'application/x-www-form-urlencoded'
        error: onError
        success: onSuccess
        type: 'DELETE'
        url: "#{appApiUrl}/#{key}"

      sendAJAXRequest(settings)

initializeiCheck = ->
  $("input[type='checkbox']").iCheck
    checkboxClass: "icheckbox_flat-blue"

  $("input[type='checkbox']").on 'ifChecked', (event) ->
    control_id = $(this).context.id
    if control_id is "chkAllDay"
      $("input[class='days']").iCheck('check')
    all_selected()

  $("input[type='checkbox']").on "ifUnchecked", (event) ->
    if !unselect_all
      control_id = $(this).context.id
      if control_id is "chkAllDay"
        $("input[class='days']").iCheck('uncheck')
      else
        unselect_all = true
        $("#chkAllDay").iCheck('uncheck')
    unselect_all = false

all_selected = ->
  if $("input[class='days']:checked").length is 7
    $("#chkAllDay").iCheck('check')

window.initializeSnapmails = ->
  loadSnapmails()
  initCameraSelect()
  initInputTags()
  initTimepicker()
  initNotification()
  saveSnapmail()
  clearForm()
  EditSnapmail()
  handleModelEvents()
  initializeiCheck()
  RemoveSnapmail()