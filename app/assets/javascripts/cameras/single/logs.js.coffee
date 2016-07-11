table = null
format_time = null
offset = null
cameraOffset = null
mouseOverCtrl = undefined

sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = $.ajax(settings)

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
        if xhr.responseJSON
          Notification.show(xhr.responseJSON.message)
        else
          Notification.show("Something went wrong, Please try again.")
        NProgress.done()
    },
    columns: [
      {data: ( row, type, set, meta ) ->
        getImage(row)
        time = row.done_at*1000
        return "
          <div class='#{row.done_at} thumb-div'>
          </div>\
          <span>#{moment(time).format('MMMM Do YYYY, H:mm:ss')}</span>"
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
    info: false,
    bPaginate: false,
    bFilter: false,
    "language": {
      "emptyTable": "No data available"
    },
    order: [[ 0, "desc" ]],
    drawCallback: ->
      NProgress.done()
  })

getImage = (row) ->
  timestamp = row.done_at
  data = {}
  data.with_data = true
  data.api_id = Evercam.User.api_id
  data.api_key = Evercam.User.api_key

  onSuccess = (response) ->
    if response.snapshots and response.snapshots.length > 0
      img_src = response.snapshots[0].data
    else
      img_src = "/assets/offline.png"
    img = $('<i>',{class: "thumbs fa fa-picture-o"})
    img.attr "aria-hidden", true
    img.attr "src",img_src
    $("#logs .#{timestamp}").empty()
    $("#logs .#{timestamp}").append(img)

  onError = (jqXHR, status, error) ->
    icon = $('<i>',{class: "thumbs fa fa-picture-o"})
    icon.attr "aria-hidden", true
    icon.attr "src", "/assets/offline.png"
    $("#logs .#{timestamp}").empty()
    $("#logs .#{timestamp}").append(icon)

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    contentType: "application/json charset=utf-8"
    type: 'GET'
    url: "#{Evercam.MEDIA_API_URL}cameras/#{Evercam.Camera.id}/recordings/snapshots/#{timestamp}"
  sendAJAXRequest(settings)

callDate = ->
  $('#datetimepicker').val(getDate('from'))
  $('#datetimepicker2').val(getDate('to'))

getDate = (type) ->
  DateFromTime = new Date(moment.utc().format('MM DD YYYY, HH:mm:ss'))
  DateFromTime.setHours(DateFromTime.getHours() + (cameraOffset))
  if type is "from"
    DateFromTime.setDate(DateFromTime.getDate() - 1)
  Dateformateed =  format_time.formatDate(DateFromTime, 'd/m/y H:i')
  return Dateformateed

onImageHover = ->
  $("#logs-table").on "mouseover", ".thumbs", ->
    data_src = $(this).attr "src"
    content_height = Metronic.getViewPort().height
    mouseOverCtrl = this
    $(".full-image").attr("src", data_src)
    $(".div-elms").show()
    thumbnail_height = $('.div-elms').height()
    thumbnail_center = (content_height - thumbnail_height) / 2
    $('.div-elms').css({"top": "#{thumbnail_center}px"})

  $("#logs-table").on "mouseout", mouseOverCtrl, ->
    $(".div-elms").hide()

window.initializeLogsTab = ->
  offset = $('#camera_time_offset').val()
  cameraOffset = parseInt(offset)/3600
  format_time = new DateFormatter()
  callDate()
  $('#apply-types').click(updateLogTypesFilter)
  $('.datetimepicker').datetimepicker(format: 'd/m/Y H:m')
  $('#type-all').click(toggleAllTypeFilters)
  jQuery.fn.DataTable.ext.type.order['string-date-pre'] = (x) ->
    return moment(x, 'MMMM Do YYYY, H:mm:ss').format('X')
  toggleCheckboxes()
  updateLogTypesFilter()
  initializeDataTable()
  onImageHover()
