#= require Chart.min.js
#= require utils.js

presets = window.chartColors
utils = Samples.utils
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
  # ["00 hr", "","","","", "", "01 hr","","","","", "", "02 hr","","","","", "", "03 hr","","","","", "", "04 hr","","","","", "", "05 hr","","","","", "", "06 hr",]
  # [8.85884, 9.58989, 5.6193, 6.54943, 1.63233, 3.1247, 6.70555, 5.95941, 7.02996, 7.10258, 7.41182, 9.933,8.85884, 9.58989, 5.6193, 6.54943, 1.63233, 3.1247, 6.70555, 5.95941, 7.02996, 7.10258, 7.41182, 9.933]
  data =
    labels: data.label
    datasets: [
      {
        backgroundColor: utils.transparentize(presets.green)
        borderColor: presets.green
        data: data.res_success
        label: 'Snapshot'
        fill: "origin"
      }
      {
        backgroundColor: utils.transparentize(presets.red)
        borderColor: presets.red
        data: data.res_error
        label: 'Error'
        fill: "origin"
      }
    ]
  options =
    maintainAspectRatio: false
    spanGaps: false
    elements: line: tension: 0.4
    scales: yAxes: [ { stacked: true } ]
    plugins:
      filler: propagate: false
  console.log data
  chart = new Chart('myChart',
    type: 'line'
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

window.initJqueryPlotResponseTime = ->
  get_responses()
