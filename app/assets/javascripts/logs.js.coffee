updateLogTypesFilter = (event) ->
  window.location = "/cameras/" + $('#exid').val() + "?page=" + $('#current-page').val() + "&types=" + $('#types').val().join() + "#logs"
  true


initializeLogsTab = ->
  $('#apply-types').click(updateLogTypesFilter)
  true

if !window.Evercam
  window.Evercam = {}

window.Evercam.Logs =
  initializeTab: initializeLogsTab