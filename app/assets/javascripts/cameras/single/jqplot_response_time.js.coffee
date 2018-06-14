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

draw_graph = (data) ->
  start_date = moment(data[0])
  arrange_datasets(data)

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
  $("#div-graph").removeClass("hide")
  # setTimeout (-> get_responses(true)), 60000
  # add_average_line()

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

window.initJqueryPlotResponseTime = ->
  get_responses()
