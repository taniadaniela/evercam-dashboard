startReport = ->
  chart = visavailChart()
  chart.width $('#visavail_container').width() - 240
  $('#draw_report').text ''
  d3.select('#draw_report').datum(Evercam.logs).call chart
  return

onResize = ->
  $(window).resize ->
    startReport()

window.initializeOnlineOfflineReport = ->
  startReport()
  onResize()
