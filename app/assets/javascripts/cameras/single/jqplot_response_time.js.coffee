#= require Chart.min.js
#= require utils.js

chart = null
presets = window.chartColors
utils = Samples.utils
start_index = 0
errors = []
success = []
sum = 0
total_success = 0
total_errors = 0

generateLabels = (date_time, count, total_errors) ->
  curr_date_time = moment()
  minutes = curr_date_time.diff(date_time, 'minutes')
  labels = [date_time.format('HH:mm:ss')]
  failed_perc = (total_errors / (Evercam.Camera.cloud_recording.frequency * minutes)) * 100

  if total_errors is 0
    $("#spn_failed_persent").text("0%")
  else
    $("#spn_failed_persent").text("#{parseFloat(failed_perc).toFixed(2)}%")

  while(start_index < count)
    labels.push ""
    start_index += 1
  labels.push curr_date_time.format('HH:mm:ss')
  labels

arrange_datasets = (data) ->
  data.splice(0, 1)
  textarea = $("#txt-response-live-tail")
  line_break = "\n"
  while(start_index < data.length)
    if start_index + 2 is data.length
      line_break = ""
    val = data[start_index + 1]
    if "#{val}".length < 4
      textarea.append("#{moment(data[start_index]*1000).format('MM/DD/YYYY HH:mm:ss')}: [error] [#{get_error_text(val)}]#{line_break}")
      errors.push val
      success.push 0
      total_errors += 1
    else
      success.push val
      textarea.append("#{moment(data[start_index]*1000).format('MM/DD/YYYY HH:mm:ss')}: [snapshot] [#{val}]#{line_break}")
      sum += val
      total_success += 1
      errors.push 0
    start_index += 2

  setTimeout(initial_scroll_to_end, 3000)
  $("#spn_success_average").text(parseFloat(sum/total_success).toFixed(4))

draw_graph = (data) ->
  start_date = moment(data[0])
  arrange_datasets(data)
  start_index = 0

  data =
    labels: generateLabels(start_date, success.length - 1, total_errors)
    datasets: [
      {
        backgroundColor: utils.transparentize('rgb(46, 204, 113)')
        borderColor: 'rgb(46, 204, 113)'
        borderWidth: 1
        data: success
        label: 'Snapshot'
      }
      {
        backgroundColor: utils.transparentize('rgb(220, 76, 63)')
        borderColor: 'rgb(220, 76, 63)'
        borderWidth: 1
        data: errors
        label: 'Error'
      }
    ]
  options =
    maintainAspectRatio: false
    scales:
      xAxes: [{
        stacked: true
        time: {unit: 'minute'}
      }]
    legend: { position: top }
    tooltips:
      custom: (tooltipModel) ->
        tooltipEl = document.getElementById('chartjs-tooltip')
        if tooltipModel and tooltipModel.body
          arr = get_error(tooltipModel.body[0].lines[0])
          if arr[0] isnt "else"
            tooltipModel.width = arr[1]
            tooltipModel.body[0].lines = [arr[0]]

  chart = new Chart('myChart',
    type: 'bar'
    data: data
    options: options)
  $("#myChart").height(250)
  # $("#div-graph").removeClass("hide")

add_average_line = ->
  c = document.getElementById("myChart")
  ctx = c.getContext("2d")
  ctx.beginPath()
  ctx.moveTo(0, 10)
  ctx.strokeStyle = "#FF0000"
  ctx.lineTo(500,10)
  ctx.stroke()

get_responses = (is_update) ->
  data =
    api_id: Evercam.User.api_id
    api_key: Evercam.User.api_key

  onError = (data) ->
    false

  onSuccess = (data) ->
    if data isnt null
      if is_update
        arrange_datasets(data)
        chart.config.data.datasets[0].data = success
        chart.config.data.datasets[1].data = errors
        chart.update()
        setTimeout (-> get_responses(true)), 60000
      else
        draw_graph(data)

  settings =
    error: onError
    success: onSuccess
    data: data
    dataType: 'json'
    contentType: "application/json charset=utf-8"
    type: "GET"
    url: "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/response-time"

  $.ajax(settings)

get_error = (str) ->
  switch str
    when "Error: 0" then ["unhandled", 80]
    when "Error: 0.5" then ["system_limit", 95]
    when "Error: 1" then ["emfile", 57]
    when "Error: 1.5" then ["case_clause", 95]
    when "Error: 2" then ["bad_request", 95]
    when "Error: 2.5" then ["closed", 59]
    when "Error: 3" then ["nxdomain", 75]
    when "Error: 3.5" then ["ehostunreach", 96]
    when "Error: 4" then ["enetunreach", 94]
    when "Error: 4.5" then ["req_timedout", 96]
    when "Error: 5" then ["timeout", 65]
    when "Error: 5.5" then ["connect_timeout", 112]
    when "Error: 6" then ["econnrefused", 103]
    when "Error: 6.5" then ["not_found", 80]
    when "Error: 7" then ["forbidden", 80]
    when "Error: 7.5" then ["unauthorized", 95]
    when "Error: 8" then ["device_error", 95]
    when "Error: 8.5" then ["device_busy", 95]
    when "Error: 9" then ["invalid_operation", 120]
    when "Error: 9.5" then ["moved", 60]
    when "Error: 10" then ["not_a_jpeg", 90]
    else ["else", 0]

get_error_text = (str) ->
  switch str
    when 0 then "unhandled"
    when 0.5 then "system_limit"
    when 1 then "emfile"
    when 1.5 then "case_clause"
    when 2 then "bad_request"
    when 2.5 then "closed"
    when 3 then "nxdomain"
    when 3.5 then "ehostunreach"
    when 4 then "enetunreach"
    when 4.5 then "req_timedout"
    when 5 then "timeout"
    when 5.5 then "connect_timeout"
    when 6 then "econnrefused"
    when 6.5 then "not_found"
    when 7 then "forbidden"
    when 7.5 then "unauthorized"
    when 8 then "device_error"
    when 8.5 then "device_busy"
    when 9 then "invalid_operation"
    when 9.5 then "moved"
    when 10 then "not_a_jpeg"
    else "Unhandled"

scroll_to_end = ->
  textarea = $("#txt-response-live-tail")
  if textarea.length
    scroll_diff = textarea[0].scrollHeight - textarea.scrollTop()
    if scroll_diff <= 400
      textarea.scrollTop(textarea[0].scrollHeight - textarea.height())

initial_scroll_to_end = ->
  textarea = $("#txt-response-live-tail")
  if textarea.length
    textarea.scrollTop(textarea[0].scrollHeight - textarea.height())

start_live_tail = ->
  Evercam.camera_channel = Evercam.socket.channel("livetail:#{Evercam.Camera.id}")
  Evercam.camera_channel.join()
  Evercam.camera_channel.on 'camera-response', (payload) ->
    textarea = $("#txt-response-live-tail")
    if payload.response_type is "ok"
      textarea.append("\n#{moment(payload.timestamp*1000).format('MM/DD/YYYY HH:mm:ss')}: [snapshot] [#{payload.response_time}]")
    else
      textarea.append("\n#{moment(payload.timestamp*1000).format('MM/DD/YYYY HH:mm:ss')}: [error] [#{payload.response_type}]")
    scroll_to_end()

stop_live_tail = ->
  Evercam.camera_channel.leave() if Evercam.camera_channel

handleTabOpen = ->
  $('.nav-tab-logs').on 'show.bs.tab', ->
    initial_scroll_to_end()
    start_live_tail()

  $('.nav-tab-logs').on 'hide.bs.tab', ->
    stop_live_tail()

window.initJqueryPlotResponseTime = ->
  get_responses()
  handleTabOpen()
