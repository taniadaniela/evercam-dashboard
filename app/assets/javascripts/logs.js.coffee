updateLogTypesFilter = () ->
  exid = $('#exid').val()
  page = $('#current-page').val()
  types = []
  $.each($("input[name='type']:checked"), ->
    types.push($(this).val())
  )
  from = new Date($('#datetimepicker').val()).getTime()/ 1000
  to = new Date($('#datetimepicker2').val()).getTime()/ 1000
  fromto_seg = ''
  fromto_seg += '&from=' + from unless isNaN(from)
  fromto_seg += '&to=' + to unless isNaN(to)
  window.location = "/cameras/" + exid + "?page=" + page + "&types=" + types.join() + fromto_seg + "#logs"
  true

initializeLogsTab = ->
  $('#apply-types').click(updateLogTypesFilter)
  $(".datetimepicker").datetimepicker()
  true

if !window.Evercam
  window.Evercam = {}

window.Evercam.Logs =
  initializeTab: initializeLogsTab