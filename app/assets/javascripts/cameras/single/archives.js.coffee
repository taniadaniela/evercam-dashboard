initDatePicker = ->
  $('.clip-datepicker').datetimepicker
    timepicker: false
    closeOnDateSelect: 0
    format: 'd/m/Y'

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

window.initializeArchivesTab = ->
  initDatePicker()
  initializeArchivesDataTable()