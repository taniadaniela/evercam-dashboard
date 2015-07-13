archives_table = null

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
  archives_table = $('#archives-table').DataTable({
    ajax: {
      url: $("#archive-api-url").val(),
      dataSrc: 'archives',
      error: (xhr, error, thrown) ->
        # Notification.show(xhr.responseJSON.message)
    },
    columns: [
      {data: "title" },
      {data: "status"},
      {data: renderDate, orderDataType: 'string-date', type: 'string-date' },
      {data: renderbuttons}
    ],
    iDisplayLength: 50,
    order: [[ 2, "desc" ]],
    bFilter: false,
    initComplete: (settings, json) ->
      $("#archives-table_length").hide()
      if json.archives.length is 0
        $(".dataTables_empty").text("There are no clips.")
        $('#archives-table_paginate, #archives-table_info').hide()
      else if json.archives.length <= 50
        $("#archives-table_info").show()
        $('#archives-table_paginate').hide()
      true
  })
  $(".dataTables_empty").text("There are no clips.")

renderbuttons = (row, type, set, meta) ->
  if row.status is "Completed"
    return '<a class="archive-actions" href="#"><i class="fa fa-play-circle"></i></a>' +
      '<a class="archive-actions" href="#"><i class="fa fa-download"></i></a>' +
      '<a class="archive-actions" href="#"><i class="fa fa-remove-sign"></i></a>'
  else
    return '<a class="archive-actions" href="#"><i class="fa fa-remove-sign"></i></a>'

renderDate = (row, type, set, meta) ->
  return moment(row.created_at*1000).format('MMMM Do YYYY, H:mm:ss')

createClip = ->
  $("#create_clip_button").on "click", ->
    data =
      title: $("#clip-name").val()
      from_date: $("#from-date").val()
      to_date: $("#to-date").val()
      embed_time: $("#embed-datetime").is(":checked")
      is_public: $("#is-public").is(":checked")

    onError = (jqXHR, status, error) ->
      Notification.show(jqXHR.responseJSON.message)
      true
    onSuccess = (data, status, jqXHR) ->
      Notification.show(data.message)
      if data.success
        archives_table.ajax.reload()
      true

    settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      type: 'POST'
      url: $("#archive-url").val()
    sendAJAXRequest(settings)

window.initializeArchivesTab = ->
  jQuery.fn.DataTable.ext.type.order['string-date-pre'] = (x) ->
    return moment(x, 'MMMM Do YYYY, H:mm:ss').format('X')
  initDatePicker()
  initializeArchivesDataTable()
  createClip()