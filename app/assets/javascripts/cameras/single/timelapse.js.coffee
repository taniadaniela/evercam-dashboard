format_time = null

initNotification = ->
  Notification.init(".bb-alert")

loadTimelapses = ->
  onError = (jqXHR, status, error) ->
    $(".bb-alert").removeClass("alert-info").addClass("alert-danger")
    Notification.show("Failed to retrive timelapses.")

  onSuccess = (timelapses, status, jqXHR) ->
    #$("#divTimelapses").append(getHtml(timelapse));
    if timelapses.length is 0
      #$("#divLoadingApps").show()
    else
      $.each timelapses.timelapses, (index, timelapse) ->
        $('#divTimelapses').append getTimelapseHtml(timelapse, index)
        initPlugins(timelapse)

  settings =
    data: {}
    dataType: 'json'
    error: onError
    success: onSuccess
    type: 'GET'
    url: "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/timelapses?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"

  $.ajax(settings)

initPlugins = (timelapse) ->
  $("#tab#{timelapse.id} .radio_edit").iCheck
    radioClass: "iradio_flat-blue"
  $("#tab#{timelapse.id} .daterange").datetimepicker({timepicker: false, format: 'd/m/Y'})
  initTimepicker("#tab#{timelapse.id} .timerange")
  videojs "video-control-#{timelapse.id}", { }

getTimelapseHtml = (timelapse, index) ->
  html = "    <div id='tab#{timelapse.id}' class='padding-bottom10'>"
  html += "        <div class='header-bg col-sm-12 padding-left0'>"
  html += "          <div class='col-sm-12 box-header-padding' data-val='#{timelapse.id}'>"
  html += "              <div id='timelapseTitle#{timelapse.id}' class='col-sm-6 timelapse-label'><div class='camera-online'></div>#{timelapse.title}&nbsp;<span class='timelapse-camera-name hide'>#{timelapse.camera_name}</span></div>"
  html += "              <div id='timelapseStatus#{timelapse.id}' class='col-sm-6 timelapse-label-status text-right'><span class='green'>#{timelapse.status}</span></div>"
  html += "          </div>"
  html += "          <div id='divContainer#{timelapse.id}' class='box-content-padding' style='display: none;'>"
  html += "              <div>"
  html += "                  <table class='tbl-tab' cellpadding='0' cellspacing='0'>"
  html += "                      <thead>"
  html += "                          <tr><th>"
  html += "                              <div class='tbl-hd2'><a class='tab-a block#{timelapse.id} selected-tab' href='javascript:;' data-ref='#divVideoContainer#{timelapse.id}' data-val='#{timelapse.id}'>View Video</a></div>"
  html += '                              <div class="tbl-hd2"><a class="tab-a block' + timelapse.id + '" href="javascript:;" data-ref="#stats' + timelapse.id + '" data-val="' + timelapse.id + '">Stats</a></div>'
  # html += '                              <div class="tbl-hd2"><a class="tab-a block' + timelapse.id + '" href="javascript:;" data-ref="#embedcode' + timelapse.id + '" data-val="' + timelapse.id + '">Embed Code</a></div>'
  html += '                              <div class="tbl-hd2"><a class="tab-a block' + timelapse.id + '" href="javascript:;" data-ref="#setting' + timelapse.id + '" data-val="' + timelapse.id + '">Settings&nbsp;&nbsp;<i class="icon-cog"></i></a></div>'
  html += '                          </th></tr>'
  html += '                       </thead>'
  html += '                       <tbody>'
  html += '                           <tr><td colspan="12" height="10px"></td></tr>'
  html += '                               <tr>'
  html += '                                   <td id="cameraCode' + timelapse.id + '" colspan="12">'
  html += '                                       <div id="divVideoContainer' + timelapse.id + '" class="active">'
  html += "                                         <video data-setup='{ \"playbackRates\": [0.06, 0.12, 0.25, 0.5, 1, 1.5, 2, 2.5, 3] }' poster='#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/thumbnail?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}' preload=\"none\" controls class=\"video-js vjs-default-skin video-bg-width\" id=\"video-control-#{timelapse.id}\">"
  html += "                                             <source type='application/x-mpegURL' src='#{Evercam.SEAWEEDFS_URL}#{timelapse.camera_id}/timelapses/#{timelapse.id}/index.m3u8'></source>"
  html += "                                         </video>"
  html += '                                       </div>'
  html += '                                       <div id="stats' + timelapse.id + '" style="display: none;">'
  html += '                                         <div class="timelapse-content-box">'
  html += '                                           <table class="table table-full-width" style="margin-bottom:0px;">'
  html += '                                             <tr><td class="col-sm-2">Total Snapshots: </td><td class="col-sm-3" id="tdSnapCount' + timelapse.id + '">' + (if timelapse.snapshot_count is null then 0 else timelapse.snapshot_count) + '</td><td class="col-sm-3" style="padding:0px;text-align:right;" align="right"><span id="imgRef' + timelapse.id + '" style="display:none;cursor:pointer;width:25px;height:25px;" data-val="' + timelapse.id + '"><i id="snaps" class="fa fa-refresh" aria-hidden="true"></i></span></td></tr>'
  html += '                                             <tr><td>File Size: </td><td colspan="2"  id="tdFileSize' + timelapse.id + '">' + 0 + '</td></tr>'
  html += '                                             <tr><td>Resolution: </td><td colspan="2"  id="tdResolution' + timelapse.id + '">' + (if timelapse.snapshot_count == 0 then '640x480' else "") + '640x480px</td></tr>'
  html += '                                             <tr><td>Created At: </td><td colspan="2"  id="tdCreated' + timelapse.id + '">' + format_time.formatDate((new Date(timelapse.created_at*1000)), "d M Y, H:i:s") + '</td></tr>'
  html += '                                             <tr><td>Last Snapshot At: </td><td colspan="2"  id="tdLastSnapDate' + timelapse.id + '">' + (if timelapse.snapshot_count == 0 then '---' else format_time.formatDate((new Date(timelapse.last_snapshot_at*1000)), "d M Y, H:i:s")) + '</td></tr>'
  html += "                                             <tr><td>HLS URL: </td><td class='hls-url-right' id='tdHlsUrl#{timelapse.id}'><input id='txtHlsUrl#{timelapse.id}' type='text' readonly class='txt-width' value='#{Evercam.SEAWEEDFS_URL}#{timelapse.camera_id}/timelapses/#{timelapse.id}/index.m3u8'/>"
  html += '                                               <span class="copy-to-clipboard" data-val="' + timelapse.id + '" alt="Copy to clipboard" title="Copy to clipboard"><i class="fa fa-files-o" aria-hidden="true"></i></span></td><td class="hls-url-left"></td></tr>'
  html += '                                             <tr><td>Timelapse Status: </td><td colspan="2"  id="tdStatus' + timelapse.id + '"><span style="margin-right:10px;" id="spnStatus' + timelapse.id + '">' + (if timelapse.status == 3 then 'Timelapse Stopped' else "Now Recordings") + '</span><button id="" type="button" data-val="' + timelapse.id + '" class="btn toggle-status" status="' + (if timelapse.status is "Paused" then 'start' else 'stop') + '">' + (if timelapse.status is "Paused" then '<i class="fa fa-play"></i> Start' else '<i class="fa fa-stop"></i> Stop') + '</button></td></tr>'
  # html += '                                           <tr><td>Rebuild Timelapse: </td><td colspan="2"  id="tdRebuild-timelaspse' + timelapse.id + '"><span id="spnRebuild-timelaspse' + timelapse.id + '">' + '</span><button type="button" id="btnRecreate' + timelapse.id + '" class="btn recreate-stream" ' + (if timelapse.recreate_hls then 'disabled="disabled"' else '') + ' camera-code="' + timelapse.id + '">' + '<i class="fa fa-retweet" aria-hidden="true"></i>' + '</button>&nbsp;&nbsp;<span id="spnRecreate' + timelapse.id + '" class="' + (if timelapse.recreate_hls then '' else 'hide') + '">Your request is under processing.</span></td></tr></table>'
  html += '                                           </table>'
  html += '                                       </div></div>'
  html += '                                       <div id="embedcode' + timelapse.id + '" style="display: none;">'
  html += '                                           <pre id="code' + timelapse.id + '" class="pre-width">&lt;div id="hls-video"&gt;&lt;/div&gt;<br/>'
  html += '&lt;script src="http://timelapse.evercam.io/timelapse_widget.js" class="' + timelapse.camera_id + ' ' + timelapse.id + ' ' + timelapse.id + '"&gt;&lt;/script&gt;</pre><br/>'
  html += '                                       </div>'

  html += "                                       <div id='setting#{timelapse.id}' style='display: none;'>"
  html += '                                         <div class="timelapse-content-box">'
  html += "                                           <table class='table' style='margin-bottom:0px;'>"
  html += "                                             <tr><td class='col-sm-2'>Title: </td><td class='col-sm-3'><input type='text' id='timelapse-title#{timelapse.id}' value='#{timelapse.title}' required='required' class='form-control'/></td><td class='col-sm-3'></td><tr>"
  html += "                                             <tr><td>Interval: </td><td><select id='timelapse-frequency#{timelapse.id}' class='form-control'>"
  html += "                                               <option value='0'>Select Interval</option>"
  html += "                                               <option #{select_frequency(timelapse.frequency, 1)} value='1'>1 Frame Every 1 min</option>"
  html += "                                               <option #{select_frequency(timelapse.frequency, 5)} value='5'>1 Frame Every 5 min</option>"
  html += "                                               <option #{select_frequency(timelapse.frequency, 15)} value='15'>1 Frame Every 15 min</option>"
  html += "                                               <option #{select_frequency(timelapse.frequency, 30)} value='30'>1 Frame Every 30 min</option>"
  html += "                                               <option #{select_frequency(timelapse.frequency, 60)} value='60'>1 Frame Every 1 hour</option>"
  html += "                                               <option #{select_frequency(timelapse.frequency, 360)} value='360'>1 Frame Every 6 hours</option>"
  html += "                                               <option #{select_frequency(timelapse.frequency, 720)} value='720'>1 Frame Every 12 hours</option></select></td><td></td>"
  html += "                                             </tr>"
  html += "                                             <tr>"
  html += "                                               <td><label>Date Range:</label></td>"
  html += "                                               <td>"
  html += "                                                 <div class='col-sm-4 radio-list padding-left0'>"
  html += "                                                   <label class='radio-inline'>"
  html += "                                                     <input id='chkDateRangeAlways' name='date_range_edit#{timelapse.id}' data-val='#{timelapse.id}' type='radio' #{select_date_time_range(timelapse.date_always, true)} value='true' class='icheck radio_edit date_range_edit'/>&nbsp;Always"
  html += "                                                   </label>"
  html += "                                                 </div>"
  html += "                                                 <div class='col-sm-4 radio-list'>"
  html += "                                                   <label class='radio-inline'>"
  html += "                                                     <input id='chkDateRange' name='date_range_edit#{timelapse.id}' data-val='#{timelapse.id}' type='radio' #{select_date_time_range(timelapse.date_always, false)} value='false' class='icheck radio_edit date_range_edit'/>&nbsp;Range"
  html += "                                                   </label>"
  html += "                                                 </div>"
  html += "                                               </td>"
  html += "                                               <td></td>"
  html += "                                             </tr>"

  html += "                                             <tr class='range-row'>"
  html += "                                               <td></td>"
  html += "                                               <td colspan='2'>"
  html += "                                                 <div id='row_date_range#{timelapse.id}' style='display: #{if timelapse.date_always then "none" else "block"};'>"
  html += "                                                   <div class='col-sm-3 padding-left0'><input type='text' id='txt_from_date#{timelapse.id}' class='form-control daterange' value='#{setDate(timelapse.date_always, timelapse.from_date, "d/m/Y", "")}' placeholder='From Date'></div>"
  html += "                                                   <div class='col-sm-3 padding-left0'><input type='text' id='txt_to_date#{timelapse.id}' class='form-control daterange' value='#{setDate(timelapse.date_always, timelapse.to_date, "d/m/Y", "")}' placeholder='To Date'></div>"
  html += "                                                 </div>"
  html += "                                               </td>"
  html += "                                             </tr>"
  html += "                                             <tr>"
  html += "                                               <td><label>Time Range:</label></td>"
  html += "                                               <td>"
  html += "                                                 <div class='col-sm-4 radio-list padding-left0'>"
  html += "                                                   <label class='radio-inline'>"
  html += "                                                     <input id='chkTimeRangeAlways' name='time_range_edit#{timelapse.id}' data-val='#{timelapse.id}' #{select_date_time_range(timelapse.time_always, true)} type='radio' value='true' class='icheck radio_edit time_range_edit' />&nbsp;Always"
  html += "                                                   </label>"
  html += "                                                 </div>"
  html += "                                                 <div class='col-sm-4 radio-list'>"
  html += "                                                   <label class='radio-inline'>"
  html += "                                                     <input id='chkTimeRange' name='time_range_edit#{timelapse.id}' data-val='#{timelapse.id}' #{select_date_time_range(timelapse.time_always, false)} type='radio' value='false' class='icheck radio_edit time_range_edit' />&nbsp;Range"
  html += "                                                   </label>"
  html += "                                                 </div>"
  html += "                                               </td>"
  html += "                                               <td></td>"
  html += "                                             </tr>"
  html += "                                             <tr class='range-row'>"
  html += "                                               <td></td>"
  html += "                                               <td colspan='2'>"
  html += "                                                 <div id='row_time_range#{timelapse.id}' style='display: #{if timelapse.time_always then "none" else "block"};padding-top:5px;'>"
  html += "                                                   <div class='col-sm-3 padding-left0'><input type='text' id='txt_from_time#{timelapse.id}' class='form-control timerange' placeholder='From Time' readonly value='#{setDate(timelapse.time_always, timelapse.from_date, "H:i", "00:00")}'></div>"
  html += "                                                   <div class='col-sm-3 padding-left0'><input type='text' id='txt_to_time#{timelapse.id}' class='form-control timerange' placeholder='To Time' readonly value='#{setDate(timelapse.time_always, timelapse.to_date, "H:i", "23:59")}'></div>"
  html += "                                                 </div>"
  html += "                                               </td>"
  html += "                                             </tr>"
  #html += "                                             <tr><td colspan='3'>&nbsp;</td></tr>"
  html += "                                             <tr>"
  html += "                                               <td></td>"
  html += "                                               <td colspan='2'>"
  html += "                                                 <button type='button' class='btn btn-primary edit-timelapse' data-val='#{timelapse.id}'><i class='fa fa-check'></i> Save</button>"
  html += "                                                 <button type='button' class='btn btn-danger delete-timelapse' data-val='#{timelapse.id}'><i class='fa fa-remove'></i> Delete</button>"
  html += "                                               </td>"
  html += "                                             </tr>"
  html += "                                           </table>"
  html += "                                       </div></div>"
  html += '                                   </td>'
  html += '                               </tr>'
  html += '                           </tbody>'
  html += '                       </table>'
  html += '                   </div>'
  html += '               </div>'
  html += '           </div></div>'
  #***********************************************************************************************************
  #if data.snaps_count == 0
  #  setTimeout (->
  #    reloadStats data.code, null
  #    return
  #  ), 1000 * 60
  html

select_frequency = (frequency, option) ->
  if frequency is option
    "selected"
  else
    ""

select_date_time_range = (is_always, option) ->
  if is_always is option
    "checked"
  else
    ""

setDate = (is_always, datetime, format, default_val) ->
  if is_always
    default_val
  else
    return format_time.formatDate((new Date(datetime*1000)), "#{format}")

copyToClipboard = ->
  $('#divTimelapses').on "click", ".copy-to-clipboard", ->
    timelapse_id = $(this).attr("data-val");
    elem = document.getElementById("txtHlsUrl#{timelapse_id}")
    # create hidden text element, if it doesn't already exist
    targetId = '_hiddenCopyText_'
    isInput = elem.tagName == 'INPUT' or elem.tagName == 'TEXTAREA'
    origSelectionStart = undefined
    origSelectionEnd = undefined
    if isInput
    # can just use the original source element for the selection and copy
      target = elem
      origSelectionStart = elem.selectionStart
      origSelectionEnd = elem.selectionEnd
    else
    # must use a temporary form element for the selection and copy
      target = document.getElementById(targetId)
      if !target
        target = document.createElement('textarea')
        target.style.position = 'absolute'
        target.style.left = '-9999px'
        target.style.top = '0'
        target.id = targetId
        document.body.appendChild target
      target.textContent = elem.textContent
    # select the content
    currentFocus = document.activeElement
    target.focus()
    target.setSelectionRange 0, target.value.length
    # copy the selection
    succeed = undefined
    try
      succeed = document.execCommand('copy')
    catch e
      succeed = false
    # restore original focus
    if currentFocus and typeof currentFocus.focus == 'function'
      currentFocus.focus()
    if isInput
    # restore prior selection
      elem.setSelectionRange origSelectionStart, origSelectionEnd
    else
    # clear temporary content
      target.textContent = ''
    succeed

show_hide_timelapse = ->
  $('#divTimelapses').on "click", ".box-header-padding", ->
    id = $(this).attr('data-val')
    if $("#divContainer#{id}").css('display') == 'none'
      $("#divContainer#{id}").slideDown 500
    else
      $("#divContainer#{id}").slideUp 500

tab_click = ->
  $('#divTimelapses').on 'click', ".tab-a", ->
    clickedTab = $(this)
    id = clickedTab.attr('data-val')
    if clickedTab.html().indexOf('Settings') >= 0
      container_id = "#setting#{id}"
      #if $(container_id).html() == ''
        #getEditTimelapseForm id
    $(".block#{id}").removeClass "selected-tab"
    clickedTab.addClass "selected-tab"
    $("#cameraCode#{id} div.active").fadeOut 100, ->
      $(this).removeClass "active"
      $(clickedTab.attr("data-ref")).fadeIn 100, ->
        $(this).addClass "active"

saveTimelapse = ->
  $('#save-timelapse').on 'click', ->
    save_button = $(this)
    $(".bb-alert").removeClass("alert-info").addClass("alert-danger")

    if $("#timelapse-title").val() is ''
      Notification.show("Please enter timelapse title.")
      return false

    if $("#timelapse-frequency").val() is "0"
      Notification.show("Please select timelapse interval.")
      return false

    d = new Date()
    fromDate = "#{(d.getMonth()+1)}/#{d.getDate()}/#{d.getFullYear()}"
    toDate = fromDate
    fromTime = "00:00"
    toTime = fromTime
    dateAlways = $('input[name=date_range]:checked').val()
    timeAlways = $('input[name=time_range]:checked').val()
    if dateAlways is "false"
      fromDate = change_date_format($("#txt_from_date").val())
      if fromDate is ""
        Notification.show("Please select from date range.")
        return false
      toDate = change_date_format($("#txt_to_date").val())
      if toDate is ""
        Notification.show("Please select to date range.")
        return false

    if timeAlways is "false"
      fromTime = $("#txt_from_time").val()
      if fromTime is ""
        Notification.show("Please select from time range.")
        return false

      toTime = $("#txt_to_time").val()
      if toTime is ""
        Notification.show("Please select to time range.")
        return false

      if fromTime is toTime
        Notification.show('To time and from time cannot be same.')
        return false

    o =
      title: $("#timelapse-title").val()
      date_always: dateAlways
      time_always: timeAlways
      frequency: $("#timelapse-frequency").val()
      from_datetime: (new Date("#{fromDate} #{fromTime}"))/1000
      to_datetime: (new Date("#{toDate} #{toTime}"))/1000

    save_button.attr 'disabled', true

    onError = (jqXHR, status, error) ->
      if jqXHR.status is 500
        Notification.show "500 Internal Server Error"
      else
        response = JSON.parse(jqXHR.responseText)
        Notification.show "#{response.message}"
      save_button.removeAttr('disabled')

    onSuccess = (result, status, jqXHR) ->
      timelapse = result.timelapses[0]
      $(".bb-alert").removeClass("alert-danger").addClass("alert-info")
      save_button.removeAttr('disabled')
      $('#divTimelapses').prepend getTimelapseHtml(timelapse, 0)
      initPlugins(timelapse)
      #videojs("#divVideoContainer#{timelapse.id}")
      $("#timelapse-form").modal("hide")
      clearForm()

    settings =
      data: o
      dataType: 'json'
      error: onError
      success: onSuccess
      type: "POST"
      url: "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/timelapses?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"

    $.ajax(settings)

editTimelapse = ->
  $('#divTimelapses').on 'click', '.edit-timelapse', ->
    save_button = $(this)
    timelapse_id = $(this).attr("data-val")
    $(".bb-alert").removeClass("alert-info").addClass("alert-danger")

    if $("#timelapse-title#{timelapse_id}").val() is ''
      Notification.show("Please enter timelapse title.")
      return false

    if $("#timelapse-frequency#{timelapse_id}").val() is "0"
      Notification.show("Please select timelapse interval.")
      return false

    d = new Date()
    fromDate = "#{(d.getMonth()+1)}/#{d.getDate()}/#{d.getFullYear()}"
    toDate = fromDate
    fromTime = "00:00"
    toTime = fromTime
    dateAlways = $("input[name=date_range_edit#{timelapse_id}]:checked").val()
    timeAlways = $("input[name=time_range_edit#{timelapse_id}]:checked").val()
    if dateAlways is "false"
      fromDate = change_date_format($("#txt_from_date#{timelapse_id}").val())
      if fromDate is ""
        Notification.show("Please select from date range.")
        return false
      toDate = change_date_format($("#txt_to_date#{timelapse_id}").val())
      if toDate is ""
        Notification.show("Please select to date range.")
        return false

    if timeAlways is "false"
      fromTime = $("#txt_from_time#{timelapse_id}").val()
      if fromTime is ""
        Notification.show("Please select from time range.")
        return false

      toTime = $("#txt_to_time#{timelapse_id}").val()
      if toTime is ""
        Notification.show("Please select to time range.")
        return false

      if fromTime is toTime
        Notification.show('To time and from time cannot be same.')
        return false

    o =
      title: $("#timelapse-title#{timelapse_id}").val()
      date_always: dateAlways
      time_always: timeAlways
      frequency: $("#timelapse-frequency#{timelapse_id}").val()
      from_datetime: (new Date("#{fromDate} #{fromTime}"))/1000
      to_datetime: (new Date("#{toDate} #{toTime}"))/1000

    save_button.attr 'disabled', true

    onError = (jqXHR, status, error) ->
      if jqXHR.status is 500
        Notification.show "500 Internal Server Error"
      else
        response = JSON.parse(jqXHR.responseText)
        Notification.show "#{response.message}"
      save_button.removeAttr('disabled')

    onSuccess = (result, status, jqXHR) ->
      snapMail = result.timelapses[0]
      $(".bb-alert").removeClass("alert-danger").addClass("alert-info")
      Notification.show('Timelapse updated.')
      save_button.removeAttr('disabled')
      # $('#divSnapmails').prepend getSnapmailHtml(snapMail, index)

    settings =
      data: o
      dataType: 'json'
      error: onError
      success: onSuccess
      type: "PATCH"
      url: "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/timelapses/#{timelapse_id}?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"

    $.ajax(settings)

deleteTimelapse = ->
  $('#divTimelapses').on 'click', '.delete-timelapse', ->
    timelapse_id = $(this).attr("data-val")
    onError = (jqXHR, status, error) ->
      if jqXHR.status is 500
        Notification.show "500 Internal Server Error"
      else
        response = JSON.parse(jqXHR.responseText)
        Notification.show "#{response.message}"

    onSuccess = (result, status, jqXHR) ->
      $(".bb-alert").removeClass("alert-danger").addClass("alert-info")
      Notification.show('Timelapse deleted successfully.')
      $("#tab#{timelapse_id}").remove()

    settings =
      data: {}
      dataType: 'json'
      error: onError
      success: onSuccess
      type: "DELETE"
      url: "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/timelapses/#{timelapse_id}?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"

    $.ajax(settings)

toggleStatus = ->
  $('#divTimelapses').on 'click', '.toggle-status', ->
    control = $(this)
    timelapse_id = $(this).attr("data-val")
    if $(this).attr("status") is 'stop'
      timelapse_status = 3
    else
      timelapse_status = 0

    onError = (jqXHR, status, error) ->
      if jqXHR.status is 500
        Notification.show "500 Internal Server Error"
      else
        response = JSON.parse(jqXHR.responseText)
        Notification.show "#{response.message}"

    onSuccess = (result, status, jqXHR) ->
      # snapMail = result.timelapses[0]
      $(".bb-alert").removeClass("alert-danger").addClass("alert-info")
      if timelapse_status is 3
        $("#timelapseStatus#{timelapse_id}").html('<span class="green">Paused</span>')
        $("#spnStatus#{timelapse_id}").text("Timelapse Stopped")
        control.attr('status', 'start')
        control.html('<i class="fa fa-play"></i> Start')
      else
        $("#timelapseStatus#{timelapse_id}").html('<span class="green">Active</span>')
        $("#spnStatus#{timelapse_id}").html("Recording now...")
        control.attr('status', 'stop')
        control.html('<i class="fa fa-stop"></i> Stop')

    settings =
      data: {status: timelapse_status}
      dataType: 'json'
      error: onError
      success: onSuccess
      type: "PATCH"
      url: "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/timelapses/#{timelapse_id}?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"

    $.ajax(settings)

clearForm = ->
  $("#timelapse-title").val("")
  $("#timelapse-frequency").val("0")
  $("#txt_from_date").val("")
  $("#txt_to_date").val("")
  $("#txt_from_time").val("00:00")
  $("#txt_to_time").val("23:59")
  $('#chkDateRangeAlways').iCheck('check');
  $("#row_date_range").slideUp()
  $('#chkTimeRangeAlways').iCheck('check');
  $("#row_time_range").slideUp()

change_date_format = (date) ->
  if date isnt ""
    dates_array = date.split("/")
    "#{dates_array[1]}/#{dates_array[0]}/#{dates_array[2]}"
  else
    ""

show_hide_datetime = ->
  $('[name="date_range"]').on 'ifClicked', ->
    id = $(this).attr('id')
    if $(this).val() is "false"
      $("#row_date_range").slideDown()
    else
      $("#row_date_range").slideUp()

  $('#divTimelapses').on 'ifClicked', '.date_range_edit', ->
    id = $(this).attr('id')
    timelapse_id = $(this).attr("data-val")
    if $(this).val() is "false"
      $("#row_date_range#{timelapse_id}").slideDown()
    else
      $("#row_date_range#{timelapse_id}").slideUp()

  $('[name="time_range"]').on 'ifClicked', ->
    id = $(this).attr('id')
    if $(this).val() is "false"
      $("#row_time_range").slideDown()
    else
      $("#row_time_range").slideUp()

  $('#divTimelapses').on 'ifClicked', '.time_range_edit', ->
    id = $(this).attr('id')
    timelapse_id = $(this).attr("data-val")
    if $(this).val() is "false"
      $("#row_time_range#{timelapse_id}").slideDown()
    else
      $("#row_time_range#{timelapse_id}").slideUp()

initTimepicker = (control) ->
  $("#{control}").timepicker
    timeFormat: 'h:i'
    minuteStep: 1
    showSeconds: false
    showMeridian: false

handleModelEvents = ->
  $("#timelapse-form").on "hide.bs.modal", ->
    clearForm()

window.initializeTimelapse = ->
  loadTimelapses()
  show_hide_datetime()
  initTimepicker(".timerange")
  handleModelEvents()
  saveTimelapse()
  show_hide_timelapse()
  tab_click()
  editTimelapse()
  toggleStatus()
  deleteTimelapse()
  copyToClipboard()
  $('.daterange').datetimepicker({timepicker: false, format: 'd/m/Y'})
  format_time = new DateFormatter()