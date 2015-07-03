initDatePicker = ->
  $('.clip-datepicker').datetimepicker
    #timepicker: false
    step: 1
    closeOnDateSelect: 0
    format: 'd/m/Y H:i:s'

initializeArchivesDataTable = ->
  table = $('#archives-table').DataTable({
    ajax: {
      url: "",
      dataSrc: 'logs',
      error: (xhr, error, thrown) ->
        Notification.show(xhr.responseJSON.message)
    },
    columns: [
      {data: "title" },
      {data: "status"},
      {data: "created_at" }
      {data: "id"}
    ],
    iDisplayLength: 50,
    order: [[ 3, "desc" ]]
  })
#Your clip has been requested.
window.initializeArchivesTab = ->
  initDatePicker()
  initializeArchivesDataTable()