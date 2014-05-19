updateLogTypesFilter = () ->
  types = []
  $.each($("input[name='type']:checked"), ->
    types.push($(this).val())
  )
  window.location = "/cameras/" + $('#exid').val() + "?page=" + $('#current-page').val() + "&types=" + types.join() + "#logs"
  true


initializeLogsTab = ->
  $('#apply-types').click(updateLogTypesFilter)
  true

if !window.Evercam
  window.Evercam = {}

window.Evercam.Logs =
  initializeTab: initializeLogsTab