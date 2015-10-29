table = null

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
  newurl = $('#base-url').val()+ "&page=" + page + "&types=" + types.join() + fromto_seg
  table.ajax.url(newurl).load() if table?
  $('#ajax-url').val(newurl) if not table?
  true

toggleAllTypeFilters = ->
  if $('#type-all').is(':checked')
    $("input[name='type']").prop("checked", true)
    $(".type-label span").addClass("checked")
  else
    $("input[name='type']").prop("checked", false)
    $(".type-label span").removeClass("checked")

initializeDataTable = ->
  table = $('#logs-table').DataTable({
    ajax: {
      url: $('#ajax-url').val(),
      dataSrc: 'logs',
      error: (xhr, error, thrown) ->
        Notification.show(xhr.responseJSON.message)
    },
    columns: [
      {data: ( row, type, set, meta ) ->
        return moment(row.done_at*1000).format('MMMM Do YYYY, H:mm:ss')
      , orderDataType: 'string-date', type: 'string-date' },
      {data: ( row, type, set, meta ) ->
        if row.action is 'shared' or row.action is 'stopped sharing'
          return row.action + ' with ' + (row.extra.with if row.extra)
        return row.action
      , className: 'log-action'},
      {data: ( row, type, set, meta ) ->
        if row.action is 'online' or row.action is 'offline'
          return 'System'
        return row.who
      }
    ],
    iDisplayLength: 50,
    order: [[ 0, "desc" ]]
  })

window.initializeLogsTab = ->
  $('#apply-types').click(updateLogTypesFilter)
  $('.datetimepicker').datetimepicker()
  $('#type-all').click(toggleAllTypeFilters)
  jQuery.fn.DataTable.ext.type.order['string-date-pre'] = (x) ->
    return moment(x, 'MMMM Do YYYY, H:mm:ss').format('X')
  updateLogTypesFilter()
  initializeDataTable()
