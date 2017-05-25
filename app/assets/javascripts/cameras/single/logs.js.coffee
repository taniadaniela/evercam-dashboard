table = null
format_time = null
offset = null
cameraOffset = null
mouseOverCtrl = undefined
evercam_logs = undefined

sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = $.ajax(settings)

updateLogTypesFilter = () ->
  NProgress.start()
  exid = $('#exid').val()
  page = $('#current-page').val()
  types = []
  $.each($("input[name='type']:checked"), ->
    types.push($(this).val())
  )
  from_date = moment($('#datetimepicker').val(), "DD-MM-YYYY H:mm")
  to_date = moment($('#datetimepicker2').val(), "DD-MM-YYYY H:mm")
  from = from_date._d.getTime()/ 1000
  to = to_date._d.getTime()/ 1000
  fromto_seg = ''
  fromto_seg += '&from=' + from unless isNaN(from)
  fromto_seg += '&to=' + to unless isNaN(to)
  newurl = $('#base-url').val()+ "&page=" + page + "&types=" + types.join() + fromto_seg
  table.ajax.url(newurl).load() if table?
  $('#ajax-url').val(newurl) if not table?
  true

toggleAllTypeFilters = ->
  $('#type-all').change ->
    status = this.checked
    $('.logs-checkbox').each ->
      this.checked = status
      if status == true
        $(".type-label span").addClass("checked")
      else
        $(".type-label span").removeClass("checked")

  $(".logs-checkbox").change ->
    if this.checked == false
      $('#type-all')[0].checked = false
      $("label[for='type-all'] span").removeClass("checked")
    if $('.logs-checkbox:checked').length == $('.logs-checkbox').length
      $('#type-all')[0].checked = true
      $("label[for='type-all'] span").addClass("checked")

toggleCheckboxes = ->
  if !$('#type-online-offline').is(':checked')
    $("input[id='type-online-offline']").prop("checked", true)
    $("label[for='type-online-offline'] span").addClass("checked")

initializeDataTable = ->
  table = $('#logs-table').DataTable({
    ajax: {
      url: $('#ajax-url').val(),
      dataSrc: (d) ->
        return format_online_log(d.logs)
      error: (xhr, error, thrown) ->
        if xhr.responseJSON
          Notification.show(xhr.responseJSON.message)
        else
          Notification.show("Something went wrong, Please try again.")
        NProgress.done()
    },
    columns: [
      {data: ( row, type, set, meta ) ->
        getImage(row)
        time = row.done_at*1000
        return "
          <div class='#{row.done_at} thumb-div'>
          </div>\
          <span>#{moment(time).format('MMMM Do YYYY, H:mm:ss')}</span>"
      , sType: 'uk_datetime' },
      {data: ( row, type, set, meta ) ->
        ip = ""
        if row.extra and row.extra.ip
          ip = ", ip: #{row.extra.ip}"
        if row.action is 'shared' or row.action is 'stopped sharing'
          if row.extra && row.extra.with
            return ("#{row.action} with #{row.extra.with}") + ip
          else
            return row.action
        if row.action is 'edited' or
          row.action is 'created' or
          row.action is 'cloud recordings updated' or
          row.action is 'cloud recordings created' or
          row.action is 'archive created' or
          row.action is 'archive deleted'
            return row.action + ip
        else if row.action is 'online'
          if row.extra
            return "<div class='onlines'>#{row.extra.message}</div>"
          else
            return '<div class="onlines">Camera came online</div>'
        else if row.extra and row.action is 'offline'
          getOfflineCause(row)
        else if row.action is 'offline'
          return '<div class="offlines">Camera went offline</div>'
        else if row.action is 'accessed'
          return 'Camera was viewed'
        else
          return row.action
      , className: 'log-action'},
      {data: ( row, type, set, meta ) ->
        if row.action is 'online' or row.action is 'offline'
          return 'System'
        return row.who
      }
    ],
    autoWidth: false,
    info: false,
    bPaginate: true,
    pageLength: 50
    "language": {
      "emptyTable": "No data available"
    },
    order: [[ 0, "desc" ]],
    drawCallback: ->
      NProgress.done()
  })

format_online_log = (logs) ->
  online = null
  offline = null
  $.each logs, (index, log) ->
    if log.action is 'online'
      online = moment(log.done_at*1000)
      tail = logs.slice((index + 1), logs.length)
      $.each tail, (i, head) ->
        if head.action is 'offline'
          offline = moment(head.done_at*1000)
          timeGet = "
            <span class='message'>after #{getTime2(online, offline)}</span>"
          logs[index].extra = {message: "Camera came online #{timeGet}"}
          return false
  return logs

getTime2 = (online, offline) ->
  s = ""
  days = online.diff(offline, "days")
  total_hours = online.diff(offline, "hours")
  hours = total_hours - (days*24)
  total_minutes = online.diff(offline, "minutes")
  minutes = total_minutes - ((days*24*60) + (hours*60))
  total_seconds = online.diff(offline, "seconds")
  seconds = total_seconds - ((days*24*60*60) + (hours*60*60) + (minutes*60))

  if days > 0
    s += days + " days, "
  if hours > 0
    s += hours + " hours, "
  if minutes > 0
    s += minutes + " mins, "
  s += seconds + " seconds"
  return s

getOfflineCause = (row) ->
  switch row.extra.reason
    when "case_clause"
      message = "Bad request."
    when "bad_request"
      message = "Bad request"
    when "closed"
      message = "Connection closed."
    when "nxdomain"
      message = "Non-existant domain."
    when "ehostunreach"
      message = "No route to host."
    when "enetunreach"
      message = "Network unreachable."
    when "req_timedout"
      message = "Request to the camera timed out."
    when "timeout"
      message = "Camera response timed out."
    when "connect_timeout"
      message = "Connection to the camera timed out."
    when "econnrefused"
      message = "Connection refused."
    when "not_found"
      message = "Camera url is not found."
    when "forbidden"
      message = "Camera responded with a Forbidden message."
    when "unauthorized"
      message = "Please check the username and password."
    when "device_error"
      message = "Camera responded with a Device Error message."
    when "device_busy"
      message = "Camera responded with a Device Busy message."
    when "moved"
      message = "Camera url has changed, please update it."
    when "not_a_jpeg"
      message = "Camera didn't respond with an image."
    when "unhandled"
      message = "Sorry, we dropped the ball."
  error = "<span class='message'>( Cause: #{message} )</span>"
  return "<div class='offlines'>Camera went offline #{error}</div>"

getImage = (row) ->
  timestamp = row.done_at
  data = {}
  data.with_data = true
  data.api_id = Evercam.User.api_id
  data.api_key = Evercam.User.api_key

  onSuccess = (response) ->
    if response.snapshots and response.snapshots.length > 0
      img_src = response.snapshots[0].data
    else
      img_src = "/assets/offline.png"
    img = $('<i>',{class: "thumbs fa fa-picture-o"})
    img.attr "aria-hidden", true
    img.attr "src",img_src
    $("#logs .#{timestamp}").empty()
    $("#logs .#{timestamp}").append(img)

  onError = (jqXHR, status, error) ->
    icon = $('<i>',{class: "thumbs fa fa-picture-o"})
    icon.attr "aria-hidden", true
    icon.attr "src", "/assets/offline.png"
    $("#logs .#{timestamp}").empty()
    $("#logs .#{timestamp}").append(icon)

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    contentType: "application/json charset=utf-8"
    type: 'GET'
    url: "#{Evercam.MEDIA_API_URL}cameras/#{Evercam.Camera.id}/recordings/snapshots/#{timestamp}"
  #sendAJAXRequest(settings)

callDate = ->
  $('#datetimepicker').val(getDate('from'))
  $('#datetimepicker2').val(getDate('to'))

getDate = (type) ->
  DateFromTime = new Date(moment.utc().format('MM DD YYYY, HH:mm:ss'))
  DateFromTime.setHours(DateFromTime.getHours() + (cameraOffset))
  if type is "from"
    DateFromTime.setDate(DateFromTime.getDate() - 1)
    DateFromTime.setHours(0)
    DateFromTime.setMinutes(0)
  if type is "to"
    DateFromTime.setHours(DateFromTime.getHours() + 2)
  Dateformated =  format_time.formatDate(DateFromTime, 'd/m/y H:i')
  return Dateformated

onImageHover = ->
  $("#logs-table").on "mouseover", ".thumbs", ->
    data_src = $(this).attr "src"
    content_height = Metronic.getViewPort().height
    mouseOverCtrl = this
    $(".full-image").attr("src", data_src)
    $(".div-elms").show()
    thumbnail_height = $('.div-elms').height()
    thumbnail_center = (content_height - thumbnail_height) / 2
    $('.div-elms').css({"top": "#{thumbnail_center}px"})

  $("#logs-table").on "mouseout", mouseOverCtrl, ->
    $(".div-elms").hide()

showStatusBar = ->
  data = {}
  data.camera_id = Evercam.Camera.id
  data.camera_name = Evercam.Camera.name
  data.camera_status = Evercam.Camera.is_online
  data.created_at = Evercam.Camera.created_at

  onSuccess = (response) ->
    initReport(response)

  onError = (jqXHR, status, error) ->
    Notification.show("Something went wrong, Please try again.")

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    contentType: "application/json charset=utf-8"
    type: 'GET'
    url: "/single_camera_status_bar"

  $.ajax(settings)

initReport = (logs) ->
  evercam_logs = logs
  chart = visavailChart()
  chart.width $('.portlet-body').width() - 240
  $('#status_bar').text ''
  d3.select('#status_bar').datum(evercam_logs).call chart
  return

doResize = ->
  $(window).resize ->
    initReport(evercam_logs)

window.initializeLogsTab = ->
  moment.locale('en')
  offset = $('#camera_time_offset').val()
  cameraOffset = parseInt(offset)/3600
  format_time = new DateFormatter()
  callDate()
  $('#apply-types').click(updateLogTypesFilter)
  $('.datetimepicker').datetimepicker(format: 'd/m/Y H:m')
  toggleAllTypeFilters()
  jQuery.fn.DataTable.ext.type.order['string-date-pre'] = (x) ->
    return moment(x, 'MMMM Do YYYY, H:mm:ss').format('X')
  toggleCheckboxes()
  updateLogTypesFilter()
  initializeDataTable()
  onImageHover()
