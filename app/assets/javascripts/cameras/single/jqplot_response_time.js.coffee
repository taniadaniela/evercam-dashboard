#= require Chart.min.js
#= require utils.js

presets = window.chartColors
utils = Samples.utils
start_index = 0

FormatNumTo2 = (n) ->
  if n < 10
    "0#{n}"
  else
    n

generateLabels = (hour, count, total_errors) ->
  d = new Date()
  curr_date_time = new Date(d.getFullYear(), d.getMonth(), d.getDate(), hour, d.getMinutes(), d.getSeconds(), d.getMilliseconds());
  date_time = new Date(d.getFullYear(), d.getMonth(), d.getDate(), hour, 0, 0, 0);
  labels = ["#{FormatNumTo2(date_time.getHours())}:#{FormatNumTo2(date_time.getMinutes())}:#{FormatNumTo2(date_time.getSeconds())}"]

  total_seconds = parseInt((curr_date_time-date_time)/1000)
  calc_minutes = Math.floor(total_seconds / 60)
  failed_perc = (total_errors / (Evercam.Camera.cloud_recording.frequency * 60)) * 100
  if total_errors is 0
    $("#spn_failed_persent").text("0%")
  else
    $("#spn_failed_persent").text("#{parseFloat(failed_perc).toFixed(2)}%")

  while(start_index < count)
    date_time.setSeconds(date_time.getSeconds() + 1);
    labels.push ""
    start_index += 1
  labels.push "#{FormatNumTo2(date_time.getHours())}:#{FormatNumTo2(d.getMinutes())}:#{FormatNumTo2(d.getSeconds())}"
  labels


draw_graph = (data) ->
  sum = 0
  total_success = 0
  total_errors = 0
  hour = data[0]
  data.splice(0, 1)
  errors = []
  success = []
  $.each data, (i, val) ->
    if "#{val}".length < 4
      errors.push val
      success.push 0
      total_errors += 1
    else
      success.push val
      sum += val
      total_success += 1
      errors.push 0
  $("#spn_success_average").text(parseFloat(sum/total_success).toFixed(4))

  data =
    labels: generateLabels(hour, success.length - 1, total_errors)
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
  $("#div-graph").removeClass("hide")
  # add_average_line()

add_average_line = ->
  c = document.getElementById("myChart")
  ctx = c.getContext("2d")
  ctx.beginPath()
  ctx.moveTo(0, 10)
  ctx.strokeStyle = "#FF0000"
  ctx.offsetX = 100000
  ctx.offsetY = 1000000
  ctx.lineTo(500,10)
  ctx.stroke()

get_responses = ->
  data =
    api_id: Evercam.User.api_id
    api_key: Evercam.User.api_key

  onError = (data) ->
    false

  onSuccess = (data) ->
    if data isnt null
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

window.initJqueryPlotResponseTime = ->
  get_responses()
