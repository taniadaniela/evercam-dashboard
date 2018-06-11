#= require Chart.min.js
#= require utils.js

presets = window.chartColors
utils = Samples.utils
labels = []
start_index = 0

inputs =
  min: 0
  max: 10
  count: 6
  decimals: 5
  continuity: 1

generateData = ->
  utils.numbers inputs

generateLabels = ->
  utils.months count: inputs.count

draw_graph = (data) ->
  errors = []
  $.each data, (i, val) ->
    labels.push ""
    if "#{val}".length < 4
      errors.push val

  data =
    labels: labels
    datasets: [
      {
        backgroundColor: utils.transparentize(presets.green)
        borderColor: presets.green
        borderWidth: 1
        data: data
        label: 'Snapshot'
      }
      {
        backgroundColor: utils.transparentize(presets.red)
        borderColor: presets.red
        borderWidth: 1
        data: errors
        label: 'Error'
      }
    ]
  options =
    maintainAspectRatio: false
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
