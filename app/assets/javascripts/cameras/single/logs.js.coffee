table = null

updateLogTypesFilter = () ->
  NProgress.start()
  exid = $('#exid').val()
  page = $('#current-page').val()
  types = []
  $.each($("input[name='type']:checked"), ->
    types.push($(this).val())
  )
  from_date = moment($('#datetimepicker').val(), "DD-MM-YYYY H:mm")
  to_date = moment($('#datetimepicker2').val(), "DD-MM-YYYY H:mm")
  from = from_date._d.getTime()/ 1000
  to = to_date._d.getTime()/ 1000
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

toggleCheckboxes = ->
  if !$('#type-online').is(':checked')
    $("input[id='type-online']").prop("checked", true)
    $("input[id='type-offline']").prop("checked", true)
    $("label[for='type-online'] span").addClass("checked")
    $("label[for='type-offline'] span").addClass("checked")

initializeDataTable = ->
  table = $('#logs-table').DataTable({
    ajax: {
      url: $('#ajax-url').val(),
      dataSrc: 'logs',
      error: (xhr, error, thrown) ->
        Notification.show("Something went wrong, Please try again.")
        NProgress.done()
    },
    columns: [
      {data: ( row, type, set, meta ) ->
        return moment(row.done_at*1000).format('MMMM Do YYYY, H:mm:ss')
      , orderDataType: 'string-date', type: 'string-date' },
      {data: ( row, type, set, meta ) ->
        if row.action is 'shared' or row.action is 'stopped sharing'
          if row.extra && row.extra.with
            return row.action + ' with ' + (row.extra.with if row.extra)
          else
            return row.action
        else if row.action is 'online'
          return '<div class="onlines">Camera came online</div>'
        else if row.action is 'offline'
          return '<div class="offlines">Camera went offline</div>'
        else if row.action is 'accessed'
          return 'Camera was viewed'
        else
          return row.action
      , className: 'log-action'},
      {data: ( row, type, set, meta ) ->
        if row.action is 'online' or row.action is 'offline'
          return 'System'
        return row.who
      }
    ],
    autoWidth: false,
    iDisplayLength: 50,
    order: [[ 0, "desc" ]],
    drawCallback: ->
      NProgress.done()
  })

window.initializeLogsTab = ->
  $('#apply-types').click(updateLogTypesFilter)
  $('.datetimepicker').datetimepicker(format: 'd/m/Y H:m')
  $('#type-all').click(toggleAllTypeFilters)
  jQuery.fn.DataTable.ext.type.order['string-date-pre'] = (x) ->
    return moment(x, 'MMMM Do YYYY, H:mm:ss').format('X')
  toggleCheckboxes()
  updateLogTypesFilter()
  initializeDataTable()

