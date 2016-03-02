archives_table = null
server_url = "http://timelapse.evercam.io/timelapses"

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
      {data: renderFromDate, orderDataType: 'string-date', type: 'string-date'},
      {data: renderToDate, orderDataType: 'string-date', type: 'string-date'},
      {data: "frames"},
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
        $('#archives-table_paginate, #archives-table_info').hide()
        $('#archives-table').hide()
        $('#archives-table_wrapper .col-sm-12').text("There are no clips.")
      else if json.archives.length < 50
        $("#archives-table_info").hide()
        $('#archives-table_paginate').hide()
      else if json.archives.length >= 50
        $("#archives-table_info").show()
        $('#archives-table_paginate').hide()
      true
  })

renderbuttons = (row, type, set, meta) ->
  if row.status is "Completed"
    mp4_url = "#{server_url}/#{row.camera_id}/archives/#{row.id}.mp4"
    view_url = "clip/#{row.id}/play"
    copy_url = ""
    if row.public is true
      copy_url = '<a href="#" class="archive-actions share-archive" play-url="' + view_url + '" val-archive-id="'+row.id+'" val-camera-id="'+row.camera_id+'"><i class="fa fa-share"></i></a>'

    return '<a class="archive-actions play-clip" href="#" play-url="' + view_url + '" ><i class="fa fa-play-circle"></i></a>' +
      '<a class="archive-actions" href="' + mp4_url + '" download="' + mp4_url + '"><i class="fa fa-download"></i></a>' +
        copy_url +
          '<a href="#" class="archive-actions delete-archive" val-archive-id="'+row.id+'" val-camera-id="'+row.camera_id+'"><i class="fa fa-remove-sign"></i></a>'
  else
    return '<a href="#" class="archive-actions delete-archive" val-archive-id="'+row.id+'" val-camera-id="'+row.camera_id+'"><i class="fa fa-remove-sign"></i></a>'

renderDate = (row, type, set, meta) ->
  return moment(row.created_at*1000).format('MMMM Do YYYY, H:mm:ss')

renderFromDate = (row, type, set, meta) ->
  return moment(row.from_date*1000).format('MMMM Do YYYY, H:mm:ss')

renderToDate = (row, type, set, meta) ->
  return moment(row.to_date*1000).format('MMMM Do YYYY, H:mm:ss')

shareURL = ->
  $("#archives-table").on "click",".share-archive", ->
    url = $(this).attr("play-url")
    share_url ="https://dash.evercam.io/v1/cameras/#{$(this).attr("val-camera-id")}/#{url}"
    copyToClipboard share_url

copyToClipboard = (text) ->
  window.prompt 'Copy to URL from here', text
  return

createClip = ->
  $("#create_clip_button").on "click", ->
    if $("#clip-name").val() is ""
      Notification.show("Clip title cannot be empty.")
      $(".bb-alert").removeClass("alert-info").addClass("alert-danger")
      return false
    $(".bb-alert").removeClass("alert-danger").addClass("alert-info")
    data =
      title: $("#clip-name").val()
      from_date: $("#from-date").val()
      to_date: $("#to-date").val()
      embed_time: $("#embed-datetime").is(":checked")
      is_public: $("#is-public").is(":checked")

    onError = (jqXHR, status, error) ->
      Notification.show(jqXHR.responseJSON.message)
      $(".bb-alert").removeClass("alert-info").addClass("alert-danger")

    onSuccess = (data, status, jqXHR) ->
      if data.success
        archives_table.ajax.reload()
        formReset()
      else
        $(".bb-alert").removeClass("alert-info").addClass("alert-danger")
      Notification.show(data.message)

    settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      type: 'POST'
      url: $("#archive-url").val()
    sendAJAXRequest(settings)

formReset = ->
  $("#clip-name").val("")
  $("#embed-datetime").prop("checked", false)
  $("#lbl-embed-datetime span").removeClass("checked")
  $("#is-public").prop("checked", false)
  $("#lbl-is-public span").removeClass("checked")
  $('#archive-modal').modal('hide')

playClip = ->
  $("#archives-table").on "click", ".play-clip", ->
    view_url = $(this).attr("play-url")
    window.open view_url, '_blank', 'width=640, Height=480, scrollbars=0, resizable=0'

deleteClip = ->
  $("#archives-table").on "click", ".delete-archive", ->
    status =  confirm 'Are you sure?'
    if !status
      return
    data =
      camera_id: $(this).attr("val-camera-id")
      archive_id: $(this).attr("val-archive-id")

    onError = (jqXHR, status, error) ->
      Notification.show(jqXHR.responseJSON.message)
      $(".bb-alert").removeClass("alert-info").addClass("alert-danger")

    onSuccess = (data, status, jqXHR) ->
      if data.success
        archives_table.ajax.reload()
      else
        $(".bb-alert").removeClass("alert-info").addClass("alert-danger")
      Notification.show(data.message)

    settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      type: 'DELETE'
      url: $("#archive-delete-url").val()
    sendAJAXRequest(settings)

window.initializeArchivesTab = ->
  jQuery.fn.DataTable.ext.type.order['string-date-pre'] = (x) ->
    return moment(x, 'MMMM Do YYYY, H:mm:ss').format('X')
  initDatePicker()
  initializeArchivesDataTable()
  createClip()
  deleteClip()
  playClip()
  shareURL()