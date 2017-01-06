startReport = ->
  l = JSON.stringify(Evercam.logs)
  $(".btn").on "click", ->
    console.log l
  # console.log Evercam.logs
  dataset = Evercam.logs
  chart = visavailChart().width(800)
  d3.select('#example').datum(dataset).call chart

window.initializeOnlineOfflineReport = ->
  startReport()
