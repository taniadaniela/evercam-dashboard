#= require Chart.min.js
#= require utils.js

presets = window.chartColors
utils = Samples.utils
start_index = 0

inputs =
  min: 0
  max: 10
  count: 6
  decimals: 5
  continuity: 1

generateData = ->
  utils.numbers inputs

FormatNumTo2 = (n) ->
  if n < 10
    "0#{n}"
  else
    n

generateLabels = (hour, success_arr, error_arr) ->
  d = new Date()
  date_time = new Date(d.getFullYear(), d.getMonth(), d.getDate(), 5, 0, 0, 0);
  labels = ["#{FormatNumTo2(date_time.getHours())}:#{FormatNumTo2(date_time.getMinutes())}:#{FormatNumTo2(date_time.getSeconds())}"]

  count = 3400
  if success_arr.length > error_arr.length
    count = success_arr.length - 1
  else
    count = error_arr.length - 1
  while(start_index < count)
    date_time.setSeconds(date_time.getSeconds() + 1);
    labels.push ""
    # labels.push "#{FormatNumTo2(date_time.getHours())}:#{FormatNumTo2(date_time.getMinutes())}:#{FormatNumTo2(date_time.getSeconds())}"
    start_index += 1
  labels.push "#{FormatNumTo2(date_time.getHours())}:#{FormatNumTo2(d.getMinutes())}:#{FormatNumTo2(d.getSeconds())}"
  labels


draw_graph = (data) ->
  sum = 0
  hour = data[0]
  data.splice(0, 1)
  errors = []
  success = []
  $.each data, (i, val) ->
    if "#{val}".length < 4
      errors.push val
      success.push null
    else
      success.push val
      errors.push null
  $("#spn_success_average").text(parseFloat(sum/success.length).toFixed(4))

  data =
    labels: generateLabels(hour, success, errors)
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
