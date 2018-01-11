archives_table = null
server_url = "http://timelapse.evercam.io/timelapses"
format_time = null
archives_data = {}

sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = $.ajax(settings)

isUnauthorized = (response) ->
  if response.responseText.indexOf("/v1/users/signin") isnt -1
    Notification.show("Your session has expired.")
    location = window.location
    location.assign(location.protocol + "//" + location.host)
  else
    Notification.show(jqXHR.responseJSON.message)

initDatePicker = ->
  $('.clip-datepicker').datetimepicker
    step: 1
    closeOnDateSelect: 0
    format: 'd/m/Y'
    timepicker: false

initializeArchivesDataTable = ->
  archives_table = $('#archives-table').DataTable({
    ajax: {
      url: $("#archive-api-url").val(),
      dataSrc: 'archives',
      error: (xhr, error, thrown) ->
    },
    columns: [
      {data: getinfo, sClass: 'archive-info'},
      {data: gravatarName, sClass: 'fullname'},
      {data: getTitle, sClass: 'title'},
      {data: renderIsPublic, orderDataType: 'string', type: 'string', sClass: 'public'},
      {data: "status", sClass: 'center'},
      {data: (row, type, set, meta) ->
        if row.type is "Compare"
          return '<i class="fa fa-file-image-o fa-3" title="Compare"></i>'
        else
          return '<i class="fa fa-video-camera fa-3" title="Clip"></i>'
      , sClass: 'text-center'},
      {data: renderbuttons, sClass: 'options'}
    ],
    iDisplayLength: 50,
    order: [[ 2, "desc" ]],
    bSort: false,
    bFilter: false,
    autoWidth: false,
    drawCallback: ->
      initializePopup()
      if archives_table
        archives_data = archives_table.data()
        refreshDataTable()
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
  if Evercam.Camera.has_edit_right || row.requested_by is Evercam.User.username
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
    inputDelete.attr("archive_type", row.type)
    inputDelete.click(deleteClip)
    divButtons.append(inputDelete)
    divButtons.append('<div class="btn delete-btn closepopup grey">' +
      '<div class="text-center" fit>CANCEL</div></div>')
    divBox2.append(divButtons)
    divCollapsePopup.append(divBox2)
    divPopup.append(divCollapsePopup)
    div.append(divPopup)
  if row.status is "Completed"
    if row.type is "Compare"
      getCompareButtons(div, row)
    else
      DateTime = new Date(moment.utc(row.created_at*1000).format('MM/DD/YYYY, HH:mm:ss'))
      day = DateTime.getDate()
      month = DateTime.getMonth()
      year = DateTime.getFullYear()
      archive_date = new Date(year, month, day)
      if archive_date < new Date(2017, 10, 1)
        mp4_url = "#{Evercam.SEAWEEDFS_URL}#{row.camera_id}/clips/#{row.id}.mp4"
      else
        mp4_url = "https://seaweedfs2.evercam.io/#{row.camera_id}/clips/#{row.id}.mp4"

      view_url = "clip/#{row.id}/play?date=#{year}-#{(parseInt(month) + 1)}-#{day}"
      copy_url = ""
      if row.public is true
        copy_url = '<a href="#" data-toggle="tooltip" title="share" class="archive-actions share-archive" play-url="' + view_url + '" val-archive-id="'+row.id+'" val-camera-id="'+row.camera_id+'"><i class="fa fa-share-alt"></i></a>'

      return '<a class="archive-actions play-clip" href="#" data-width="640" data-height="480" data-toggle="tooltip" title="Play" play-url="' + view_url + '"><i class="fa fa-play-circle"></i></a>' +
        '<a id="archive-download-url' + row.id + '" class="archive-actions" data-toggle="tooltip" title="Download" href="' + mp4_url + '" download="' + mp4_url + '"><i class="fa fa-download"></i></a>' +
          copy_url + div.html()
  else
    return div.html()

getCompareButtons = (div, row) ->
  animation_url = "#{Evercam.API_URL}cameras/#{row.camera_id}/compares/#{row.id}"
  view_url = ""
  copy_url = ""
  return '<div class="dropdown"><a class="archive-actions dropdown-toggle" href="#" data-toggle="dropdown" title="Play"><i class="fa fa-play-circle"></i></a>' +
    '<ul class="dropdown-menu"><li><a class="play-clip" href="#" title="Play GIF" data-width="1280" data-height="720" play-url="' + animation_url + '.gif"><i class="fa fa-play-circle"></i> GIF</a></li>'+
      '<li><a class="play-clip" href="#" title="Play MP4" data-width="1280" data-height="720" play-url="' + animation_url + '.mp4"><i class="fa fa-play-circle"></i> MP4</a></li></ul>' +
    '</div>' +
    '<div class="dropdown float-left"><a class="archive-actions dropdown-toggle" href="#" data-toggle="dropdown" title="Download"><i class="fa fa-download"></i></a>' +
    '<ul class="dropdown-menu"><li><a class="download-archive" href="' + animation_url + '.gif" title="Download GIF" download="' + animation_url + '.gif"><i class="fa fa-download"></i> GIF</a></li>'+
      '<li><a class="download-archive" href="' + animation_url + '.mp4" title="Download MP4" download="' + animation_url + '.mp4"><i class="fa fa-download"></i> MP4</a></li></ul>' +
    '</div>' +
    copy_url + div.html()

getinfo = (row, type, set, meta) ->
  start_index = row.embed_code.indexOf("#{Evercam.Camera.id}")
  end_index = row.embed_code.indexOf("autoplay")
  return "<a class='td-archive-info' href='#' data-id='#{row.id}' data-type='#{row.type}' data-toggle='modal' data-target='#modal-archive-info'><i class='fa fa-info-circle fa-4'></i></a>
    <input id='txtArchiveThumb#{row.id}' type='hidden' value='#{row.thumbnail}'>
    <input id='txt_frames#{row.id}' type='hidden' value='#{row.frames}'>
    <input id='txt_duration#{row.id}' type='hidden' value='#{renderDuration(row, type, set, meta)}'>
    <input id='archive_embed_code#{row.id}' type='hidden' value='#{row.embed_code.substring(start_index, end_index)}'/>"

getTitle = (row, type, set, meta) ->
  return "<div class='div-title'>#{row.title} <br /><small class='blue'>#{renderFromDate(row, type, set, meta)} - #{renderToDate(row, type, set, meta)}</small></div>"

gravatarName = (row, type, set, meta) ->
  main_div = $('<div>', {class: "main_div"})
  div = $('<div>', {class: "gravatar-placeholder"})
  img = $('<img>', {class: "gravatar #{row.id}"})
  div.append(img)
  div_user = $('<div>', {class: "username-id"})
  if row.requester_email
    div_user.append(row.requester_name)
  else
    div_user.append("Deleted User")
  div_user.append('<br>')
  small = $('<small>', {class: "blue"})
  small.append(renderDate(row, type, set, meta))
  div_user.append(small)
  main_div.append(div)
  main_div.append(div_user)
  changeImageSource(row.requester_email, row.id)
  return main_div.html()

changeImageSource = (email, id) ->
  favicon_url = "https://favicon.yandex.net/favicon/"
  if email
    signature = hex_md5(email)
    index = email.indexOf("@")
    domain = email.substr((index+1))
    favicon_url = favicon_url + domain
    img_src = "https://gravatar.com/avatar/#{signature}?d=#{favicon_url}"
    if domain is "hotmail.com"
      img_src = "https://gravatar.com/avatar/#{signature}"
  else
    img_src = "https://gravatar.com/avatar"

  data = {}

  onSuccess = (data, success, jqXHR) ->
    length = jqXHR.responseText.length
    if length < 100
      img_src = "https://gravatar.com/avatar/#{signature}"
    $("#archives-table .#{id}").attr "src", img_src

  onError = (jqXHR, status, error) ->
    $("#archives-table .#{id}").attr "src", img_src

  settings =
    cache: false
    data: data
    dataType: 'html'
    error: onError
    success: onSuccess
    type: 'GET'
    url: "#{favicon_url}"
  jQuery.ajax(settings)

renderDate = (row, type, set, meta) ->
  getDate(row.created_at*1000)

renderFromDate = (row, type, set, meta) ->
  getDates(row.from_date*1000)

renderToDate = (row, type, set, meta) ->
  getDates(row.to_date*1000)

renderDuration = (row, type, set, meta) ->
  if row.type is "Compare"
    return "9 secs"
  else
    dateTimeFrom = new Date(
      moment.utc(row.from_date*1000).
      format('MM/DD/YYYY,HH:mm:ss')
    )
    dateTimeTo = new Date(
      moment.utc(row.to_date*1000).
      format('MM/DD/YYYY, HH:mm:ss')
    )
    diff = dateTimeTo - dateTimeFrom
    diffSeconds = diff / 1000
    HH = Math.floor(diffSeconds / 3600)
    MM = Math.floor(diffSeconds % 3600) / 60
    MM = Math.round(MM)
    HH = (HH + 1) if MM is 60
    hours = HH + ' ' + if HH is 1 then 'hr' else 'hrs'
    hours = '' if HH is 0
    minutes = MM + ' ' + if MM is 1 then 'min' else 'mins'
    minutes = '' if MM is 0
    minutes = '' if MM is 60
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
  DateTime = new Date(moment.utc(times).format('MM/DD/YYYY, HH:mm:ss'))
  DateTime.setHours(DateTime.getHours() + (cameraOffset))
  Dateformateed =  format_time.formatDate(DateTime, 'd/m/y H:i')
  return Dateformateed

getDate = (timestamp) ->
  offset =  $('#camera_time_offset').val()
  cameraOffset = parseInt(offset)/3600
  DateTime = new Date(moment.utc(timestamp).format('MM/DD/YYYY, HH:mm:ss'))
  DateTime.setHours(DateTime.getHours() + (cameraOffset))
  Dateformateed = format_time.formatDate(DateTime, 'd M Y, H:i:s')
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

FormatNumTo2 = (n) ->
  num = parseInt(n)
  if num < 10
    "0#{num}"
  else
    num

createClip = ->
  $("#create_clip_button").on "click", ->
    duration = parseInt($("#to-date").val())
    date = $("#from-date").val().split('/')
    time = $('.timepicker-default').val().split(":")
    from = moment.tz("#{date[2]}-#{FormatNumTo2(date[1])}-#{FormatNumTo2(date[0])} #{FormatNumTo2(time[0])}:#{FormatNumTo2(time[1])}:00", "UTC")
    to = from.clone().minutes(from.minutes() + duration)

    if $("#clip-name").val() is ""
      Notification.show("Clip title cannot be empty.")
      $(".bb-alert").removeClass("alert-info").addClass("alert-danger")
      return false
    if duration > 60
      Notification.show("Duration exceeds maximum limit of 60 min.")
      $(".bb-alert").removeClass("alert-info").addClass("alert-danger")
      return false
    $(".bb-alert").removeClass("alert-danger").addClass("alert-info")
    NProgress.start()
    $("#create_clip_button").attr 'disabled', 'disabled'

    data =
      title: $("#clip-name").val()
      from_date: from / 1000
      to_date: to / 1000
      is_nvr_archive: $("#txtCreateArchiveType").val()
      requested_by: Evercam.User.username

    onError = (jqXHR, status, error) ->
      if jqXHR.status is 500
        Notification.show("Internal Server Error. Please contact to admin.")
      else
        Notification.show(jqXHR.responseJSON.message)
      $(".bb-alert").removeClass("alert-info").addClass("alert-danger")
      NProgress.done()
      $("#create_clip_button").removeAttr 'disabled'

    onSuccess = (data, status, jqXHR) ->
      if $("#txtCreateArchiveType").val() isnt ""
        window.vjs_player_local.pause()
        $("#clip-create-message").show()
      archives_table.ajax.reload (json) ->
        $('#archives-table').show()
        $("#no-archive").hide()
        NProgress.done()
        formReset()
        setDate()
        $("#create_clip_button").removeAttr 'disabled'

    settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      type: 'POST'
      url: "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/archives?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"
    $.ajax(settings)

setToDate = (date, duration) ->
  dates = date.split(" ")
  date = dates[0]
  date_arr = date.split('/')
  time = dates[1]
  time_arr = time.split(":")
  new_date = new Date(
    date_arr[2],date_arr[1] - 1,date_arr[0],
    time_arr[0],time_arr[1]
  )
  min = $('#archive-time').data('timepicker').minute
  new_date.setMinutes(parseInt(min) + parseInt(duration))
  set_date = format_time.formatDate(new_date, 'd/m/Y H:i:s')
  return set_date

setDate = ->
  offset =  $('#camera_time_offset').val()
  cameraOffset = parseInt(offset)/3600
  DateTime = new Date(moment.utc().format('MM/DD/YYYY'))
  Datefrom = format_time.formatDate(DateTime, 'd/m/Y')
  $('#from-date').val Datefrom,true

formReset = ->
  $("#clip-name").val("")
  $('#archive-modal').modal('hide')

playClip = ->
  $("#archives-table").on "click", ".play-clip", ->
    width = parseInt($(this).attr("data-width"))
    height = parseInt($(this).attr("data-height"))
    view_url = $(this).attr("play-url")
    window.open view_url, '_blank', "width=#{width}, Height=#{height}, scrollbars=0, resizable=0"

  $("#archives-table").on "click", ".download-archive", ->
    NProgress.start()
    setTimeout( ->
      NProgress.done()
    , 4000)

cancelForm = ->
  $('#archive-modal').on 'hidden.bs.modal', ->
    $("#clip-name").val("")
    setDate()

deleteClip = ->
  $('#archives').on 'click','.delete-archive2', ->
    NProgress.start()
    control = $(this)
    data =
      camera_id: control.attr("camera_id")
      archive_id: control.attr("archive_id")

    onError = (jqXHR, status, error) ->
      isUnauthorized(jqXHR)
      $(".bb-alert").removeClass("alert-info").addClass("alert-danger")
      NProgress.done()

    onSuccess = (data, status, jqXHR) ->
      if control.attr("archive_type") is "Compare"
        refresh_archive_table()
        Notification.show("Compare deleted successfully.")
      else
        if data.success
          refresh_archive_table()
          Notification.show(data.message)
        else
          $(".bb-alert").removeClass("alert-info").addClass("alert-danger")
          NProgress.done()
          Notification.show("Only requester or full-rights user can delete this archive.")

    api_url = $("#archive-delete-url").val()
    if control.attr("archive_type") is "Compare"
      api_url = "#{Evercam.API_URL}cameras/#{control.attr("camera_id")}/compares/#{control.attr("archive_id")}?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"

    settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      type: 'DELETE'
      url: api_url
    sendAJAXRequest(settings)

refresh_archive_table = ->
  archives_table.ajax.reload (json) ->
    if json.archives.length is 0
      $('#archives-table_paginate, #archives-table_info').hide()
      $('#archives-table').hide()
      $("#no-archive").show()
    NProgress.done()

initializePopup = ->
  $(".popbox2").popbox
    open: ".open-archive"
    box: ".box2"
    arrow: ".arrow"
    arrow_border: ".arrow-border"
    close: ".closepopup"

refreshDataTable = ->
  status =  jQuery.map(archives_data, (arr) ->
    arr.status
  )
  if ($.inArray('Pending', status)) != -1
    setTimeout archives_table.ajax.reload, 60000
  else if ($.inArray('Processing', status)) != -1
    setTimeout archives_table.ajax.reload, 30000

window.on_export_compare = ->
  archives_table.ajax.reload()
  $('#archives-table').show()
  $("#no-archive").hide()
  refreshDataTable()

modal_events = ->
  $("#archives"). on "click", ".td-archive-info", ->
    id = $(this).attr("data-id")
    type = $(this).attr("data-type")
    query_string = $("#archive_embed_code#{id}").val()
    $('#archive-thumbnail').attr("src", $("#txtArchiveThumb#{id}").val())
    url = "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/compares/#{id}"
    $("#archive_gif_url").val("#{url}.gif")
    $("#archive_mp4_url").val("#{url}.mp4")
    code = "<div id='evercam-compare'></div><script src='#{window.location.origin}/assets/evercam_compare.js' class='#{query_string} autoplay'></script>"
    $("#archive_embed_code").val(code)
    $("#div_frames").text($("#txt_frames#{id}").val())
    $("#div_duration").text($("#txt_duration#{id}").val())
    if type isnt "Compare"
      $("#row-embed-code").hide()
      $("#row-gif").hide()
      $("#archive_mp4_url").val($("#archive-download-url#{id}").attr("href"))
    else
      $("#row-embed-code").show()
      $("#row-gif").show()

window.initializeArchivesTab = ->
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
  cancelForm()
  modal_events()
