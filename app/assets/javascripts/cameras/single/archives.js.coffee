sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = $.ajax(settings)

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
  $(".dataTables_empty").text("There are no clips.")

createClip = ->
  $("#").on "click", ->
    true

window.initializeArchivesTab = ->
  initDatePicker()
  initializeArchivesDataTable()