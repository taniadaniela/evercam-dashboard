startReport = ->
  dataset = Evercam.logs
  chart = visavailChart().width(800)
  d3.select('#draw_report').datum(dataset).call chart

window.initializeOnlineOfflineReport = ->
  startReport()
