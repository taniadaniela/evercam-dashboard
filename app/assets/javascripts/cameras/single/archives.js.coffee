archives_table = null
server_url = "http://timelapse.evercam.io/timelapses"
format_time = null
owner = null
current_user = null

sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = $.ajax(settings)

initDatePicker = ->
  $('.clip-datepicker').datetimepicker
    step: 1
    closeOnDateSelect: 0
    format: 'd/m/Y H:i:s'

initializeArchivesDataTable = ->
  archives_table = $('#archives-table').DataTable({
    ajax: {
      url: $("#archive-api-url").val(),
      dataSrc: 'archives',
      error: (xhr, error, thrown) ->
    },
    columns: [
      {data: gravatarName, sClass: 'fullname'},
      {data: "title", sClass: 'title' },
      {data: renderFromDate, orderDataType: 'string-date', type: 'string-date', sClass: 'from'},
      {data: renderToDate, orderDataType: 'string-date', type: 'string-date', sClass: 'to'},
      {data: renderDuration, orderDataType: 'string-date', type: 'string-date', sClass: 'duration'},
      {data: "frames", sClass: 'frames'},
      {data: renderIsPublic, orderDataType: 'string', type: 'string', sClass: 'public'},
      {data: "status", sClass: 'status'},
      {data: renderbuttons, sClass: 'options'}
    ],
    iDisplayLength: 50,
    order: [[ 2, "desc" ]],
    bSort: false,
    bFilter: false,
    autoWidth: false,
    drawCallback: ->
      initializePopup()
    initComplete: (settings, json) ->
      $("#archives-table_length").hide()
      if json.archives.length is 0
        $('#archives-table_paginate, #archives-table_info').hide()
        $('#archives-table').hide()
        span = $("<span>")
        span.append($(document.createTextNode("There are no clips.")))
        span.attr("id", "no-archive")
        $('#archives-table_wrapper .col-sm-12').append(span)
      else if json.archives.length < 50
        $("#archives-table_info").hide()
        $('#archives-table_paginate').hide()
      else if json.archives.length >= 50
        $("#archives-table_info").show()
        $('#archives-table_paginate').hide()
      true
  })

renderbuttons = (row, type, set, meta) ->
  div = $('<div>', {class: "form-group"})
  if Evercam.Camera.is_owner
    divPopup =$('<div>', {class: "popbox2"})
    remove_icon = '<span href="#" data-toggle="tooltip" title="Delete" ' +
      'class="archive-actions delete-archive" val-archive-id="'+row.id+
      '" val-camera-id="'+row.camera_id+'">' +
      '<i class="fa fa-trash-o"></i></span>'
    span = $('<span>', {class: "open-archive"})
    span.append(remove_icon)
    divPopup.append(span)
    divCollapsePopup = $('<div>', {class: "collapse-popup"})
    divBox2 = $('<div>', {class: "box2"})
    divBox2.append($('<div>', {class: "arrow"}))
    divBox2.append($('<div>', {class: "arrow-border"}))
    divMessage = $('<div>', {class: "margin-bottom-10"})
    divMessage.append($(document.createTextNode("Are you sure?")))
    divBox2.append(divMessage)
    divButtons = $('<div>', {class: "margin-bottom-10"})
    inputDelete = $('<input type="button" value="Yes, Remove">')
    inputDelete.addClass("btn btn-primary delete-btn delete-archive2")
    inputDelete.attr("camera_id", Evercam.Camera.id)
    inputDelete.attr("archive_id", row.id)
    inputDelete.click(deleteClip)
    divButtons.append(inputDelete)
    divButtons.append('<div class="btn delete-btn closepopup grey">' +
      '<div class="text-center" fit>CANCEL</div></div>')
    divBox2.append(divButtons)
    divCollapsePopup.append(divBox2)
    divPopup.append(divCollapsePopup)
    div.append(divPopup)
  if row.status is "Completed"
    mp4_url = "#{server_url}/#{row.camera_id}/archives/#{row.id}.mp4"
    view_url = "clip/#{row.id}/play"
    copy_url = ""
    if row.public is true
      copy_url = '<a href="#" data-toggle="tooltip" title="share" class="archive-actions share-archive" play-url="' + view_url + '" val-archive-id="'+row.id+'" val-camera-id="'+row.camera_id+'"><i class="fa fa-share-alt"></i></a>'

    return '<a class="archive-actions play-clip" href="#" data-toggle="tooltip" title="Play" play-url="' + view_url + '" ><i class="fa fa-play-circle"></i></a>' +
      '<a class="archive-actions" data-toggle="tooltip" title="Download" href="' + mp4_url + '" download="' + mp4_url + '"><i class="fa fa-download"></i></a>' +
        copy_url + div.html()
  else
    return div.html()

gravatarName = (row, type, set, meta) ->
  main_div = $('<div>', {class: "main_div"})
  div = $('<div>', {class: "gravatar-placeholder"})
  signature = hex_md5(row.requester_email)
  img_src = "//gravatar.com/avatar/#{signature}.png"
  img = $('<img>', {class: "gravatar"})
  img.attr("src", img_src)
  div.append(img)
  div_user = $('<div>', {class: "username-id"})
  div_user.append(row.requester_name)
  div_user.append('<br>')
  small = $('<small>', {class: "blue"})
  small.append(renderDate(row, type, set, meta))
  div_user.append(small)
  main_div.append(div)
  main_div.append(div_user)
  return main_div.html()

renderDate = (row, type, set, meta) ->
  getDate(row.created_at*1000)

renderFromDate = (row, type, set, meta) ->
  getDates(row.from_date*1000)

renderToDate = (row, type, set, meta) ->
  getDates(row.to_date*1000)

renderDuration = (row, type, set, meta) ->
  dateTimeFrom = new Date(moment.utc(row.from_date*1000).format('MM DD YYYY, HH:mm:ss'))
  dateTimeTo = new Date(moment.utc(row.to_date*1000).format('MM DD YYYY, HH:mm:ss'))
  diff = dateTimeTo - dateTimeFrom
  diffSeconds = diff / 1000
  HH = Math.floor(diffSeconds / 3600)
  hours = HH + ' ' + 'hr'
  hours = '' unless HH isnt 0
  MM = Math.floor(diffSeconds % 3600) / 60
  MM = Math.round(MM)
  minutes = MM + ' ' +'min'
  minutes = '' unless MM isnt 0
  formatted = hours + ' ' + minutes
  return formatted

renderIsPublic = (row, type, set, meta) ->
  if row.public
    return 'Yes'
  else
    return 'No'

getDates = (times) ->
  offset =  $('#camera_time_offset').val()
  cameraOffset = parseInt(offset)/3600
  DateTime = new Date(moment.utc(times).format('MM DD YYYY, HH:mm:ss'))
  DateTime.setHours(DateTime.getHours() + (cameraOffset))
  Dateformateed =  format_time.formatDate(DateTime, 'm/d/y H:i')
  return Dateformateed

getDate = (timestamp) ->
  offset =  $('#camera_time_offset').val()
  cameraOffset = parseInt(offset)/3600
  DateTime = new Date(moment.utc(timestamp).format('MM DD YYYY, HH:mm:ss'))
  DateTime.setHours(DateTime.getHours() + (cameraOffset))
  Dateformateed = format_time.formatDate(DateTime, 'M d Y, H:i:s')
  return Dateformateed

shareURL = ->
  $("#archives-table").on "click",".share-archive", ->
    url = $(this).attr("play-url")
    share_url ="https://dash.evercam.io/v1/cameras/#{$(this).attr("val-camera-id")}/#{url}"
    copyToClipboard share_url

copyToClipboard = (text) ->
  window.prompt 'Copy to URL from here', text
  return

tooltip = ->
  $('[data-toggle="tooltip"]').tooltip()
  return

createClip = ->
  $("#create_clip_button").on "click", ->
    if $("#clip-name").val() is ""
      Notification.show("Clip title cannot be empty.")
      $(".bb-alert").removeClass("alert-info").addClass("alert-danger")
      return false
    $(".bb-alert").removeClass("alert-danger").addClass("alert-info")
    NProgress.start()
    data =
      title: $("#clip-name").val()
      from_date: $("#from-date").val()
      to_date: $("#to-date").val()
      embed_time: $("#embed-datetime").is(":checked")
      is_public: $("#is-public").is(":checked")

    onError = (jqXHR, status, error) ->
      Notification.show(jqXHR.responseJSON.message)
      $(".bb-alert").removeClass("alert-info").addClass("alert-danger")
      NProgress.done()

    onSuccess = (data, status, jqXHR) ->
      if data.success
        archives_table.ajax.reload (json) ->
          $('#archives-table').show()
          $("#no-archive").hide()
          NProgress.done()
        formReset()
      else
        $(".bb-alert").removeClass("alert-info").addClass("alert-danger")
        NProgress.done()
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

setDate = ->
  $('.btn-primary').on 'click', ->
    offset =  $('#camera_time_offset').val()
    cameraOffset = parseInt(offset)/3600
    DateTime = new Date(moment.utc().format('MM DD YYYY, HH:mm:ss'))
    DateTime.setHours(DateTime.getHours() + (cameraOffset))
    Dateto =  format_time.formatDate(DateTime, 'd/m/Y H:i:s')
    $('#to-date').val Dateto,true
    DateTime.setHours(DateTime.getHours() - 2)
    Datefrom = format_time.formatDate(DateTime, 'd/m/Y H:i:s')
    $('#from-date').val Datefrom,true

formReset = ->
  $("#clip-name").val("")
  $('#archive-modal').modal('hide')
  $("#embed-datetime").prop("checked", false)
  $("#lbl-embed-datetime span").removeClass("checked")
  $("#is-public").prop("checked", false)
  $("#lbl-is-public span").removeClass("checked")

playClip = ->
  $("#archives-table").on "click", ".play-clip", ->
    view_url = $(this).attr("play-url")
    window.open view_url, '_blank', 'width=640, Height=480, scrollbars=0, resizable=0'

deleteClip = ->
  $('#archives').on 'click','.delete-archive2', ->
    NProgress.start()
    control = $(this)
    data =
      camera_id: control.attr("camera_id")
      archive_id: control.attr("archive_id")

    onError = (jqXHR, status, error) ->
      Notification.show(jqXHR.responseJSON.message)
      $(".bb-alert").removeClass("alert-info").addClass("alert-danger")
      NProgress.done()

    onSuccess = (data, status, jqXHR) ->
      if data.success
        archives_table.ajax.reload (json) ->
          if json.archives.length is 0
            $('#archives-table_paginate, #archives-table_info').hide()
            $('#archives-table').hide()
            $("#no-archive").show()
          NProgress.done()
          Notification.show(data.message)
      else
        $(".bb-alert").removeClass("alert-info").addClass("alert-danger")
        NProgress.done()
        Notification.show("Only the Camera Owner can delete this clip.")

    settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      type: 'DELETE'
      url: $("#archive-delete-url").val()
    sendAJAXRequest(settings)

initializePopup = ->
  $(".popbox2").popbox
    open: ".open-archive"
    box: ".box2"
    arrow: ".arrow"
    arrow_border: ".arrow-border"
    close: ".closepopup"

window.initializeArchivesTab = ->
  owner = $('#camera_owner').val()
  current_user = $('#current_user').val()
  format_time = new DateFormatter()
  jQuery.fn.DataTable.ext.type.order['string-date-pre'] = (x) ->
    return moment(x, 'MMMM Do YYYY, H:mm:ss').format('X')
  initDatePicker()
  initializeArchivesDataTable()
  tooltip()
  createClip()
  playClip()
  shareURL()
  setDate()
  deleteClip()
