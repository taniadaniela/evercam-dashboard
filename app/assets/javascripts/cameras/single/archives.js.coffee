upload = null;
uploadIsRunning = false;
archives_table = null
server_url = "http://timelapse.evercam.io/timelapses"
format_time = null
archives_data = {}
xhrRequestCheckSnapshot = null
has_snapshots = false
archive_js_player = null
archive_js_player2 = null
imagesCompare = undefined
is_reload = true
is_list_view = true
pagination = false
archive_id_from_url = null

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
  $('#recording-archive-button').on "click", ->
    GetSnapshotInfo()
  $('.clip-datepicker').datetimepicker
    step: 1
    closeOnDateSelect: 0
    format: 'd/m/Y'
    timepicker: false
    onSelectDate: (ct, $i) ->
      if $("#txtCreateArchiveType").val() is ""
        GetSnapshotInfo()

  $("#archive-time").on "keyup", ->
    if $("#txtCreateArchiveType").val() is ""
      GetSnapshotInfo()

  $("#to-date").on "keyup", ->
    if $("#txtCreateArchiveType").val() is ""
      GetSnapshotInfo()

initializeArchivesDataTable = ->
  archives_table = $('#archives-table').DataTable({
    ajax: {
      url: $("#archive-api-url").val(),
      dataSrc: 'archives',
      error: (xhr, error, thrown) ->
    },
    columns: [
      {data: getTitle, sClass: 'title', orderable: false},
      {data: gravatarName, sType: "uk_datetime"},
      {data: renderIsPublic, sClass: 'public', orderable: false},
      {data: rendersharebuttons, sClass: 'center', "searchable": false, orderable: false},
      {data: renderStatus, sClass: 'center', visible: false},
      {data: "type", sClass: 'text-center', visible: false},
      {data: renderbuttons, sClass: 'options', visible: true, "searchable": false, orderable: false}
    ],
    iDisplayLength: 50,
    aaSorting: [1, "desc"]
    bFilter: true,
    autoWidth: false,
    drawCallback: ->
      initializePopup() if is_reload
      is_reload = true
      if archives_table
        archives_data = archives_table.data()
        load_archive_view_by_id(archives_data)
        table_init_complete(archives_data)
        initializeArchivesDataBox()
        refreshDataTable()
    initComplete: (settings, json) ->
      table_init_complete(json.archives)
  })

table_init_complete = (archives) ->
  $("#archives-table_length").hide()
  $("#archives-table_filter").hide()
  if archives.length is 0
    $('#archives-table_paginate, #archives-table_info').hide()
    $('#archives-table').hide()
    span = $("<span>")
    span.append($(document.createTextNode("There are no clips.")))
    span.attr("id", "no-archive")
    $('#archives-table_wrapper .col-sm-12').append(span)
  else if archives.length < 50
    $("#archives-table_info").hide()
    $('#archives-table_paginate').hide()
    pagination = false
  else if archives.length >= 50
    $("#archives-table_info").show()
    $('#archives-table_paginate').show()
    pagination = true

load_archive_view_by_id = (archives) ->
  if archive_id_from_url
    archive = search_by_id(archives, archive_id_from_url)
    $("#archive_url_link_#{archive_id}").click()
    archive_id_from_url = null

    id = archive.id
    file_name = archive.file_name
    file_type = null
    type = archive.type
    status = archive.status
    camera_id = archive.camera_id
    media_url = get_media_url(id, camera_id, file_name, archive.media_url, type)
    media_title = archive.title
    media_autor = archive.requester_name
    requested_by = archive.requested_by
    media_from = moment.tz(archive.from_date*1000, Evercam.Camera.timezone).format('MM/DD/YYYY, HH:mm:ss')
    media_to = moment.tz(archive.to_date*1000, Evercam.Camera.timezone).format('MM/DD/YYYY, HH:mm:ss')
    media_thumbnail = archive.thumbnail_url
    media_time = archive.created_at
    media_ispublic = "#{archive.public}"
    newTime = moment.tz(media_time * 1000, Evercam.Camera.timezone)

    if Evercam.Camera.has_edit_right || requested_by is Evercam.User.username
      $("#popup-delete-view").show()
    else
      $("#popup-delete-view").hide()

    if type is "compare"
      $("#archive-play video").attr("loop", "true")
    else
      $("#archive-play video").attr("loop", "false")

    if type is "clip" || type is "compare" || type is "url" || type is "file" || type is "edit"
      update_request_url(id)
      $('#archives-table_paginate').hide()
      $("#archives-table_info").hide()
      $("#toggle-tabs").hide()
      $("#archives-table").hide()
      $("#archives-box").show()
      $("#back-archives").show()
      $("#back-button").show()
      $("#camera-video-archive").show()
      $(".archive-tabs").hide()
      $(".hide-add-button").hide()
      $("#archives-box-2").hide()
      $(".stackimage").removeClass("stackimage-view")
      $(".stackimage").addClass("stackimage-player")
      $("#archives-tab").removeClass("margin-top-15")
      $('#txt_title').text(media_title)
      $('#archive-autor').html("Requested by: #{media_autor}</br>")
      $('#archive-dates').html("From #{media_from} to #{media_to}</br>")
      $('#archive-time-1').text("Created at #{moment(newTime).format('MMMM Do YYYY, H:mm:ss')}")
      $("#archives").css("width", "80%")
      $("#archives").css("margin-left", "10%")
      $("#txt-archive-type").val(type)
      $("#txt-archive-id").val(id)
      $("#txt-archive-title").val(media_title)
      $('.hide-add-button').hide()
      $('#player-buttons').empty()
      $('#player-buttons').append renderplayerbuttons(requested_by, id, camera_id, type, status, media_url, media_ispublic, file_name)
      calculateHeight()

      if type is "url"
        $("#archive-play").hide()
        $("#file_upload_viewer").hide()
        $("#archive-dates").hide()
        $("#iframe_archive").show()
        info_total = $("#back-button").height() + $("#info-archive").height() + $(".player-header").height() + $("#ul-nav-tab").height() + 52
        view_height = Metronic.getViewPort().height
        $("#iframe_archive").height(view_height - info_total)
        $('#iframe_archive').prop('src', convert_to_embed_url(media_url))
      else if type is "file" || type is "edit"
        arr = file_name.split('.')
        file_type = get_file_type(arr.pop())
        $("#iframe_archive").hide()
        $('#archive-dates').html("Cloud Recordings #{media_from}</br>")
        if type is "file"
          $("#archive-dates").hide()
        if file_type is "image"
          $("#archive-play").hide()
          $("#file_upload_viewer").show()
          $("#file_upload_viewer").attr("src", media_url)
        else
          $("#archive-play").show()
          $("#file_upload_viewer").hide()
          load_player(media_thumbnail, media_url)
      else
        $("#file_upload_viewer").hide()
        $("#iframe_archive").hide()
        $("#archive-play").show()
        $("#archive-dates").show()
        load_player(media_thumbnail, media_url)

search_by_id = (archives, archive_id) ->
  found_archive = null
  $.each archives, (i, archive) ->
    if archive.id is archive_id
      found_archive = archive
  return found_archive

get_media_url = (id, camera_id, file_name, media_url, type) ->
  url = "#{Evercam.API_URL}cameras/#{camera_id}/archives/#{id}.mp4?api_key=#{Evercam.User.api_key}&api_id=#{Evercam.User.api_id}"

  if type is "url"
    url = media_url
  else if type is "edit"
    url = "#{Evercam.API_URL}cameras/#{camera_id}/archives/#{file_name}?api_key=#{Evercam.User.api_key}&api_id=#{Evercam.User.api_id}"
  else if type is "file"
    url = "#{Evercam.API_URL}cameras/#{camera_id}/archives/#{file_name}?api_key=#{Evercam.User.api_key}&api_id=#{Evercam.User.api_id}"
  else if type is "compare"
    url = "#{Evercam.API_URL}cameras/#{camera_id}/compares/#{id}.mp4?api_key=#{Evercam.User.api_key}&api_id=#{Evercam.User.api_id}"
  return url

getArchiveIdFromUrl = ->
  archive_id_from_url = window.Evercam.request.subpath.
    replace(RegExp("archives", "g"), "").
    replace(RegExp("/", "g"), "")

hover_thumbnail = ->
  $("#archives-tab").on "mousemove", ".gravatar", (ev) ->
    view_width = Metronic.getViewPort().width
    view_height = Metronic.getViewPort().height
    $("#fullsize-thumbnail").attr("src", $(this).attr("src"))
    thumbnail_width = $("#fullsize-thumbnail").width()
    thumbnail_height =$("#fullsize-thumbnail").height()
    top = ev.pageY
    screen_top = ev.screenY
    if ((view_height - screen_top) < thumbnail_height)
      hidden_height = thumbnail_height - (view_height - screen_top)
      top = (top - hidden_height)

    if $(".page-sidebar").css('display') is "block"
      left = ev.pageX + 10
      if view_width < left + thumbnail_width + 10
        left = left - (left + thumbnail_width - view_width) - 30
    else
      left = ev.pageX + 10

    $("#div-full-thumbnail").css({ top: "#{top}px", left: "#{left}px" })
    $("#div-full-thumbnail").show()

  $("#archives-tab").on "mouseout", ".gravatar", (ev) ->
    $("#div-full-thumbnail").hide()

toggleView = ->
  if is_list_view
    $("#archives-table").show()
    $("#archives-box").hide()
    $("#archives-tab").addClass("margin-top-15")
  else
    $("#archives-box").hide()
    $("#archives-table").show()
    $("#archives-tab").removeClass("margin-top-15")

  $("#toggle-grid").on "click", ->
    $("#archives-tab").addClass("margin-top-15")
    $("#archives-table").hide()
    $("#archives-box").show()
    $(".archive-tabs").hide()
    $("#archives").css("width", "100%")
    $("#archives").css("margin-left", "0")
    $(".hide-add-button").show()
    $(".stackimage").addClass("stackimage-view")
    $(".stackimage").removeClass("stackimage-player")
    $("#archives-box-2").show()
    $("#camera-video-archive").hide()
    $('#archives-table_paginate').hide()
    $("#archives-table_info").hide()
    $("#back-archives").hide()
    $("#back-button").hide()
    is_list_view = false

  $("#toggle-list").on "click", ->
    $("#archives-tab").addClass("margin-top-15")
    $(".archive-tabs span").show()
    $("#archives-box").hide()
    $("#archives-table").show()
    $(".archive-tabs").show()
    $("#archives").css("width", "100%")
    $("#archives").css("margin-left", "0")
    if pagination
      $('#archives-table_paginate').show()
      $("#archives-table_info").show()
    is_list_view = true

  $("#back-archives").on "click", ->
    hide_player_view()

sortByKey = (array, key) ->
  array.sort (a, b) ->
    x = a[key]
    y = b[key]
    (if (x < y) then -1 else ((if (x > y) then 1 else 0)))

initializeArchivesDataBox = ->
  $("#archives-box-2").html("")
  archives = sortByKey(archives_data, "created_at").reverse()
  $.each archives_data, (index, archives) ->
    $("#archives-box-2").append getArchivesHtml(archives)

getTime = (dateBefore, dateAfter) ->
  timeDiff = Math.abs(dateAfter - dateBefore)
  diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24))
  return diffDays

getArchivesHtml = (archives) ->
  hide_dates = ""
  image_html = "<img alt='#{archives.title}' src='#{archives.thumbnail_url}' class='stackimage stackimage-view' style='visibility: visible' id='stackimage-#{archives.title}'></a>"
  if archives.type is "clip"
    fa_class = "<svg width='50' height='50' viewBox='0 0 24 24' fill='none' stroke='#000000' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'>
    <polygon points='23 7 16 12 23 17 23 7'></polygon>
    <rect x='1' y='5' width='15' height='14' rx='2' ry='2'></rect>
    </svg>"
    url = "#{Evercam.API_URL}cameras/#{archives.camera_id}/archives/#{archives.id}/play?api_key=#{Evercam.User.api_key}&api_id=#{Evercam.User.api_id}"
  else if archives.type is "compare"
    fa_class = "<svg fill='#000000' height='50' viewBox='0 0 24 24' width='50'>
      <path d='M0 0h24v24H0z' fill='none'/>
      <path d='M10 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h5v2h2V1h-2v2zm0 15H5l5-6v6zm9-15h-5v2h5v13l-5-6v9h5c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2z'/>
      </svg>"
    url = "#{Evercam.API_URL}cameras/#{archives.camera_id}/compares/#{archives.id}.mp4"
  else if archives.type is "file"
    arr = archives.file_name.split('.')
    file_type = get_file_type(arr.pop())
    url = "#{Evercam.API_URL}cameras/#{archives.camera_id}/archives/#{archives.file_name}?api_key=#{Evercam.User.api_key}&api_id=#{Evercam.User.api_id}"
    fa_class = "<i class='fa fa-upload type-icon type-icon-url'></i>"
    hide_dates = "hide"
  else if archives.type is "edit"
    arr = archives.file_name.split('.')
    file_type = get_file_type(arr.pop())
    url = "#{Evercam.API_URL}cameras/#{archives.camera_id}/archives/#{archives.file_name}?api_key=#{Evercam.User.api_key}&api_id=#{Evercam.User.api_id}"
    fa_class = "<i class='fa fa-image type-icon type-icon-url'></i>"
  else
    arr_host = getHostName(archives.media_url).split('.')
    domain = arr_host.shift()
    url = archives.media_url
    image_html = "<div class='stacklink_view'><i class='fab fa-#{domain} #{domain}'></i></div>"
    fa_class = "<i class='fa fa-link type-icon type-icon-url'></i>"
    hide_dates = "hide"

  html = "<div id='dataslot#{archives.id}' class='list-border margin-bottom10'>"
  html += "    <div class='padding-left-0' style='min-height:0px;'>"
  html += "    <div class='col-xs-12 col-sm-6 col-md-3 card-archives' style='min-height:0px;'>"
  html += "             <div class='gravatar-placeholder'><div class='type-icon-alignment-big'>#{fa_class}</div></div>"
  html += "        <div class='snapstack-loading' id='snaps-#{archives.id}' >"
  html += "           <a class='archive-title-color' data-ispublic='#{archives.public}' data-file-type='#{file_type}' data-file-name='#{archives.file_name}' data-status='#{archives.status}' data-camera='#{archives.camera_id}' data-type='#{archives.type}' data-id='#{archives.id}' data-url='#{url}' data-thumbnail='#{archives.thumbnail_url}' data-title='#{archives.title}' data-to='#{getDates(archives.to_date * 1000)}' data-from='#{getDates(archives.from_date * 1000)}' data-time='#{archives.created_at}' data-autor='#{archives.requester_name}'>"
  html += image_html
  html += "        </div>"
  html += "        <div class='card-padding'>"
  html += "        <div class='camera-email'>"
  html += "          <div class='nav-tabs div-archive-values'><a class='archive-title-color' data-file-type='#{file_type}' data-file-name='#{archives.file_name}' data-ispublic='#{archives.public}' data-status='#{archives.status}' data-camera='#{archives.camera_id}' data-type='#{archives.type}' data-id='#{archives.id}' data-url='#{url}' data-thumbnail='#{archives.thumbnail_url}' data-title='#{archives.title}' data-to='#{getDates(archives.to_date * 1000)}' data-from='#{getDates(archives.from_date * 1000)}' data-time='#{archives.created_at}' data-autor='#{archives.requester_name}'>#{archives.title}</a>"
  html += "          </div>"
  html += "          <span class='spn-label'><i class='fas fa-users'></i></span><div class='div-snapmail-values snapmail-title' title='#{archives.requester_name}'><span class='small-text'>&nbsp;&nbsp;#{archives.requester_name}</span><span class='line-end'></span></div><div class='clear-f'></div>"
  if archives.type is "edit"
    html += "          <span class='spn-label'><i class='far fa-calendar-alt font-16'></i></span><div class='div-snapmail-values snapmail-title'><span class='small-text'>&nbsp;&nbsp;#{moment.tz(archives.from_date * 1000, Evercam.Camera.timezone).format('MM/DD/YYYY, HH:mm:ss')}</span><span class='line-end'></span></div><div class='clear-f'></div>"
  else
    html += "          <span class='spn-label'><i class='far fa-calendar-alt font-16'></i></span><div class='div-snapmail-values snapmail-title #{hide_dates}'><span class='small-text'>&nbsp;&nbsp;#{getDates(archives.from_date * 1000)} - #{getDates(archives.to_date * 1000)}</span><span class='line-end'></span></div><div class='clear-f'></div>"
  html += "          <span class='spn-label'><i class='far fa-clock font-16'></i></span><div class='div-snapmail-values snapmail-title'><span class='small-text'>&nbsp;&nbsp;#{moment(archives.created_at*1000).format("MMMM Do YYYY, H:mm:ss")}</span><span class='line-end'></span></div><div class='clear-f'></div></div>"
  html += "    </div>"
  html += "    </div>"
  html += "</div>"
  html

renderplayerbuttons = (requested_by, id, camera_id, type, status, media_url, media_ispublic, file_name) ->
  div = $('<div>', {class: "form-group"})

  if status is "Completed"
    if type is "url"
      return div.html()
    else if type is "compare"
      animation_url = "#{Evercam.API_URL}cameras/#{camera_id}/compares/#{id}"
      return "<a class='archive-actions dropdown-toggle archive-title' href='#'' title='share' data-id='#{id}' data-type='#{type}' data-toggle='modal' data-target='#modal-archive-info'><i class='fas fa-share-alt'></i> Share</a>" +
        "'<input id='gif-#{id}' value= '#{animation_url}.gif' type='hidden'>" +
        "<input id='mp4-#{id}' value='#{animation_url}.mp4' type='hidden'>" +
        "<div id='download-button' class='dropdown float-right'><a class='archive-actions dropdown-toggle' href='#' data-toggle='dropdown' title='Download'><i class='fa fa-download'></i> Download</a>" +
        "<ul class='dropdown-menu'>
          <li><a class='download-animation archive-icon' href='javascript:;' data-download-target='#gif-#{id}' title='Download GIF'><i class='fa fa-download'></i> GIF</a></li>" +
          "<li><a class='download-animation archive-icon' href='javascript:;' data-download-target='#mp4-#{id}' title='Download MP4'><i class='fa fa-download'></i> MP4</a></li></ul>" +
        "</div>" + div.html()
    else
      mp4_media_url = "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/archives/#{id}.mp4"
      is_enable = ""
      if media_ispublic isnt "true"
        is_enable = "hide"
      share_button = "<a id='share-link-#{id}' class='archive-actions archive-title #{is_enable}' href='#' title='share' data-file-name='#{file_name}' data-id='#{id}' data-url='#{media_url}' data-type='#{type}' data-status='#{status}' data-camera_id='#{camera_id}' data-ispublic='#{media_ispublic}' data-toggle='modal' data-target='#modal-archive-info'><i class='fas fa-share-alt'></i> share</a>"

      publicButtons = renderIsPublicPlayer(id, type, status, media_ispublic, true)

      return "<div class='dropdown'>" + share_button +
        '<div style="display:inline-block;cursor:pointer;" class=" archive-actions"><a class="download-animation archive-icon" data-download-target="#mp4clip-' + id  + '" title="Download MP4"><i class="fa fa-download"></i> Download</a></div>' +
        div.html() + publicButtons
  else
    return div.html()

renderbuttons = (row, type, set, meta) ->
  div = $('<div>', {class: "form-group"})
  if Evercam.Camera.has_edit_right || row.requested_by is Evercam.User.username
    divPopup =$('<div>', {class: "popbox2"})
    divPopup.attr("id", "popbox2-#{row.id}")
    remove_icon = '<span href="#" data-toggle="tooltip" title="Delete" ' +
      'class="archive-actions delete-archive" val-archive-id="'+row.id+
      '" val-camera-id="'+row.camera_id+'">' +
      '<i class="fas fa-trash-alt"></i></span>'

    span = $('<span>', {class: "open-archive"})
    span.attr("id", "open-archive-#{row.id}")
    span.append(remove_icon)
    divPopup.append(span)
    divCollapsePopup = $('<div>', {class: "collapse-popup"})

    divBox2 = $('<div>', {class: "box2"})
    divBox2.attr("id", "box2-#{row.id}")

    divArrow = $('<div>', {class: "arrow"})
    divArrow.attr("id", "arrow-#{row.id}")
    divBox2.append(divArrow)

    divArrowBorder = $('<div>', {class: "arrow-border"})
    divArrowBorder.attr("id", "arrow-border-#{row.id}")
    divBox2.append(divArrowBorder)

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
    divButtons.append('<div id="closepopup-#{row.id}" class="btn delete-btn closepopup grey">' +
      '<div class="text-center" fit>CANCEL</div></div>')
    divBox2.append(divButtons)
    divCollapsePopup.append(divBox2)
    divPopup.append(divCollapsePopup)
    div.append(divPopup)
  if row.status is "Completed"
    if row.type is "compare"
      getCompareButtons(div, row)
    else if row.type is "file" || row.type is "edit"
      getFileButtons(row, div)
    else if row.type is "url"
      return "<a class='archive-actions archive-title' href='javascript:;' title='Edit' data-id='#{row.id}' data-url='#{row.media_url}' data-type='#{row.type}' data-toggle='modal' data-target='#social-media-url-modal'><i class='fas fa-edit'></i></a>" +
      "<a target='_blank' class='archive-actions' href='#{row.media_url}'><i class='fa fa-external-link-alt'></i></a>#{div.html()}"
    else
      mp4_url = "#{Evercam.API_URL}cameras/#{row.camera_id}/archives/#{row.id}"
      view_url = "clip/#{row.id}/play"
      copy_url = ""

      return '<div class="dropdown">' +
        '<a class="archive-actions play-clip" href="javascript:;" data-width="640" data-height="480" data-toggle="tooltip" title="Play" play-url="' + view_url + '"><i class="fa fa-play-circle"></i></a>' +
        '<input id="mp4clip-' + row.id + '" value= "' + mp4_url + '.mp4" type="hidden">' +
        '<input id="mp4play-' + row.id + '" value= "' + mp4_url + '/play?api_key='+ Evercam.User.api_key + '&api_id=' + Evercam.User.api_id + '" type="hidden">' +
          copy_url + div.html()
  else
    return div.html()

rendersharebuttons = (row, type, set, meta) ->
  div = $('<div>', {class: "form-group"})
  url = ""
  if row.status is "Completed"
    if row.type is "url"
      return ''
    else
      url = "#{Evercam.API_URL}cameras/#{row.camera_id}/archives/#{row.id}.mp4"
      download_link = '<div class="float-left"><a class="archive-actions download-animation archive-icon" href="javascript:;" data-download-target="#mp4clip-' + row.id  + '"><i class="fa fa-download" title="Download MP4"></i></a></div>'
      copy_url_link = "<a href='javascript:;' data-toggle='tooltip' title='Copy URL' class='archive-actions share-archive' play-url='#{url}' val-archive-id='#{row.id}' val-camera-id='#{row.camera_id}'><i class='fas fa-link'></i></a>"

      if row.type is "file" || row.type is "edit"
        url = "#{Evercam.API_URL}cameras/#{row.camera_id}/archives/#{row.file_name}"
        copy_url_link = "<a href='javascript:;' data-toggle='tooltip' title='Copy URL' class='archive-actions share-archive' play-url='#{url}' val-archive-id='#{row.id}' val-camera-id='#{row.camera_id}'><i class='fas fa-link'></i></a>"
      else if row.type is "compare"
        main_url = "#{Evercam.API_URL}cameras/#{row.camera_id}/compares/#{row.id}"
        url = "#{main_url}.mp4"
        download_link = '<div class="dropdown"><a class="archive-actions dropdown-toggle" href="#" data-toggle="dropdown" title="Download"><i class="fa fa-download"></i></a>' +
                        '<ul class="dropdown-menu"><li><a class="download-animation archive-icon" href="javascript:;" data-download-target="#gif-' + row.id + '" title="Download GIF"><i class="fa fa-download"></i> GIF</li></a>'+
                          '<li><a class="download-animation archive-icon" href="javascript:;" data-download-target="#mp4-' + row.id  + '" title="Download MP4"><i class="fa fa-download "></i> MP4</a></li></ul>' +
                        '</div>'
        copy_url_link = "<div class='dropdown'><a class='archive-actions dropdown-toggle' href='#'' data-toggle='dropdown' title='Download'><i class='fas fa-link'></i></a>" +
                        "<ul class='dropdown-menu'><li><a class='share-archive archive-icon' href='javascript:;' play-url='#{main_url}.gif' title='Copy GIF URL'><i class='fas fa-link'></i> GIF</li></a>" +
                          "<li><a class='share-archive archive-icon' href='javascript:;' play-url='#{main_url}.mp4' title='Copy MP4 URL'><i class='fas fa-link'></i> MP4</a></li></ul>" +
                        "</div>"

      if row.public
        return download_link + '<div class="enabled share-buttons"><div class="dropdown"><a href="http://www.facebook.com/sharer.php?u=' + url + '" class="archive-actions" target="_blank" title="Facebook" data-width="1280" data-height="720"><i class="fab fa-facebook-f"></i></a>' +
            '<a href="http://www.linkedin.com/shareArticle?url=' + url + '&title=My photo&summary=This is a photo from evercam" class="archive-actions" target="_blank" title="Linkedin" data-width="1280" data-height="720"><i class="fab fa-linkedin-in"></i></a>' +
            '<a href="http://twitter.com/share?url=' + url + '&text=This is an archive from evercam&via=evrcm" class="archive-actions" target="_blank" title="Twitter" data-width="1280" data-height="720"><i class="fab fa-twitter"></i></a></div>' +
            copy_url_link + div.html()
      else
        return download_link + '<div class="disabled share-buttons">'+
            '<a href="http://www.facebook.com/sharer.php?u=" class="archive-actions" target="_blank" title="Facebook" data-width="1280" data-height="720"><i class="fab fa-facebook-f"></i></a>'+
            '<a href="http://www.linkedin.com/shareArticle?url=&title=My photo&summary=This is a photo from evercam" class="archive-actions" target="_blank" title="Linkedin" data-width="1280" data-height="720"><i class="fab fa-linkedin-in"></i></a>' +
            '<a href="http://twitter.com/share?url=&text=This is a photo from evercam&via=evrcm" class="archive-actions" target="_blank" title="Twitter" data-width="1280" data-height="720"><i class="fab fa-twitter"></i></a>' +
            '<a href="#" data-toggle="tooltip" title="Copy URL" class="archive-actions share-archive" play-url="" val-archive-id="' + row.id + '" val-camera-id="' + row.camera_id + '"><i class="fas fa-link"></i></a></div>'+
            div.html()
  else
    return div.html()

makePublic = ->
  $("#archives-tab").on "change", ".toggle_input_public", ->
    is_checked = $(this)
    id = $(this).attr('alt')
    typeArchive = $(this).attr('archive_type')

    onError = (jqXHR, status, error) ->
      if jqXHR.status is 500
        Notification.show("Internal Server Error. Please contact to admin.")
      else
        Notification.show(jqXHR.responseJSON.message)
      $(".bb-alert").removeClass("alert-info").addClass("alert-danger")
      NProgress.done()
      $("#create_clip_button").removeAttr 'disabled'

    onSuccess = (data, status, jqXHR) ->
      index = $("input.toggle_input_public").index(this)
      if is_checked.is(":checked")
        is_checked.attr("checked")
        $(".share-buttons:eq(#{index})").removeClass('disabled').addClass('enabled')
        $("#share-buttons-player").removeClass('disabled').addClass('enabled')
        $("#share-link-#{id}").removeClass("hide")
        $("#share-link-#{id}").attr("data-ispublic", "true")
      else
        is_checked.removeAttr("checked")
        $(".share-buttons:eq(#{index})").removeClass('enabled').addClass('disabled')
        $("#share-buttons-player").removeClass('enabled').addClass('disabled')
        $("#share-link-#{id}").addClass("hide")
        $("#share-link-#{id}").attr("data-ispublic", "false")
      refresh_archive_table()

    if typeArchive isnt "compare"
      settings =
        cache: false
        data: {public: $(this).is(":checked")}
        dataType: 'json'
        error: onError
        success: onSuccess
        type: 'PATCH'
        url: "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/archives/#{id}?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"
      $.ajax(settings)
    else
      refresh_archive_table()
      Notification.show("The comparisons are always public")

getCompareButtons = (div, row) ->
  animation_url = "#{Evercam.API_URL}cameras/#{row.camera_id}/compares/#{row.id}"
  view_url = ""
  copy_url = ""
  return '<div class="dropdown">' +
    '<a class="margin-right12 archive-actions" href="javascript:;" data-toggle="dropdown" title="Play"><i class="fa fa-play-circle"></i></a>' +
    '<ul class="dropdown-menu"><li><a class="play-clip" href="javascript:;" title="Play GIF" data-width="1280" data-height="720" play-url="' + animation_url + '.gif"><i class="fa fa-play-circle"></i> GIF</a></li>'+
      '<li><a class="play-clip" href="javascript:;" title="Play MP4" data-width="1280" data-height="720" play-url="' + animation_url + '.mp4"><i class="fa fa-play-circle"></i> MP4</a></li></ul>' +
    '</div>' +
    '<input id="gif-' + row.id + '" value= "' + animation_url + '.gif" type="hidden">' +
    '<input id="mp4-' + row.id + '" value= "' + animation_url + '.mp4" type="hidden">' +
    copy_url + div.html()

getFileButtons = (row, div) ->
  arr = row.file_name.split('.')
  fileType = get_file_type(arr.pop())
  snap_date_time = moment.tz(row.from_date * 1000, Evercam.Camera.timezone).format('MM/DD/YYYY, HH:mm:ss')
  file_url = ""
  edit_link = ""
  if fileType is "image"
    file_url = "#{Evercam.API_URL}cameras/#{row.camera_id}/archives/#{row.file_name}?api_key=#{Evercam.User.api_key}&api_id=#{Evercam.User.api_id}"
    edit_link = "<a class='archive-actions archive-image-edit' href='javascript:;' title='Edit Image' data-from='#{snap_date_time}' data-time=#{row.created_at} data-autor='#{row.requester_name}' data-id='#{row.id}' data-url='#{file_url}' data-title='#{row.title}'><i class='fas fa-edit'></i></a>"
  else
    file_url = "#{Evercam.API_URL}cameras/#{row.camera_id}/archives/#{row.file_name}?api_key=#{Evercam.User.api_key}&api_id=#{Evercam.User.api_id}"
  return edit_link + "#{div.html()}<input id='mp4clip-#{row.id}' value='#{file_url}' type='hidden'>"

getTitle = (row, type, set, meta) ->
  start_index = row.embed_code.indexOf("#{Evercam.Camera.id}")
  mp4Url = "#{Evercam.API_URL}cameras/#{row.camera_id}/archives/#{row.id}/play?api_key=#{Evercam.User.api_key}&api_id=#{Evercam.User.api_id}"
  if row.embed_code.indexOf("autoplay") > 0
    end_index = row.embed_code.indexOf("autoplay")
  else
    end_index = row.embed_code.indexOf("'></script>")
  query_string = row.embed_code.substring(start_index, end_index) if row.embed_code

  archive_inputs = "<input id='txtArchiveThumb#{row.id}' type='hidden' value='#{row.thumbnail_url}'><input id='txtArchiveTitle#{row.id}' type='hidden' value='#{row.title}'>"

  if row.type is "url"
    arr_host = getHostName(row.media_url).split('.')
    domain = arr_host.shift()
    return "<div class='gravatar-placeholder'><div class='social-media-icon'><i class='fab fa-#{domain} #{domain}'></i></div><div class='type-icon-alignment'><i class='fa fa-link type-icon type-icon-url'></i></div></div>
      <div class='media-url-title'>
      <a id='archive_url_link_#{row.id}' class='archive-title-color' data-ispublic='#{row.public}' data-status='#{row.status}' data-camera='#{row.camera_id}' data-url='#{row.media_url}' data-thumbnail='#{row.thumbnail}' data-title='#{row.title}' data-from='#{renderFromDate(row, type, set, meta)}' data-to='#{renderToDate(row, type, set, meta)}' data-time=#{row.created_at} data-requester-by='#{row.requested_by}' data-autor='#{row.requester_name}' data-id='#{row.id}' data-type='#{row.type}'>#{row.title}</a>
      </div>#{archive_inputs}"
  else if row.type is "edit"
    arr = row.file_name.split('.')
    file_type = get_file_type(arr.pop())
    snap_date_time = moment.tz(row.from_date * 1000, Evercam.Camera.timezone).format('MM/DD/YYYY, HH:mm:ss')
    file_url = "#{Evercam.API_URL}cameras/#{row.camera_id}/archives/#{row.file_name}?api_key=#{Evercam.User.api_key}&api_id=#{Evercam.User.api_id}"
    return "<div class='gravatar-placeholder'><img class='gravatar' src='#{row.thumbnail_url}'><div class='type-icon-alignment'><i class='fa fa-image type-icon type-icon-url'></i></div><div class='float-left'></div>
      <div class='username-id'>
      <a id='archive_url_link_#{row.id}' class='archive-title-color' data-file-name='#{row.file_name}' data-file-type='#{file_type}' data-ispublic='#{row.public}' data-status='#{row.status}' data-camera='#{row.camera_id}' data-url='#{file_url}' data-thumbnail='#{row.thumbnail}' data-title='#{row.title}' data-from='#{snap_date_time}' data-to='#{renderToDate(row, type, set, meta)}' data-time=#{row.created_at} data-requester-by='#{row.requested_by}' data-autor='#{row.requester_name}' data-id='#{row.id}' data-type='#{row.type}'>#{row.title}</a>
      <br /><small class='blue'>Cloud Recording #{snap_date_time}</small></div></div>#{archive_inputs}"
  else if row.type is "file"
    arr = row.file_name.split('.')
    file_type = get_file_type(arr.pop())
    file_url = "#{Evercam.API_URL}cameras/#{row.camera_id}/archives/#{row.file_name}?api_key=#{Evercam.User.api_key}&api_id=#{Evercam.User.api_id}"
    if get_file_type(arr.pop()) is "other"
      file_link = "<a target='_blank' href='#{file_url}' class='archive-title-color'>#{row.title}</a>"
    else
      file_link = "<a id='archive_url_link_#{row.id}' class='archive-title-color' data-file-name='#{row.file_name}' data-file-type='#{file_type}' data-ispublic='#{row.public}' data-status='#{row.status}' data-camera='#{row.camera_id}' data-url='#{file_url}' data-thumbnail='#{row.thumbnail}' data-title='#{row.title}' data-from='#{renderFromDate(row, type, set, meta)}' data-to='#{renderToDate(row, type, set, meta)}' data-time=#{row.created_at} data-requester-by='#{row.requested_by}' data-autor='#{row.requester_name}' data-id='#{row.id}' data-type='#{row.type}'>#{row.title}</a>"

    return "<div class='gravatar-placeholder'><img class='gravatar' src='#{row.thumbnail_url}'><div class='type-icon-alignment'><i class='fa fa-upload type-icon type-icon-url'></i></div></div>
      <div class='media-url-title'>
      #{file_link}</div>#{archive_inputs}"
  else
    fa_class = "<i class='fas fa-video type-icon'></i>"
    if row.type is "compare"
      mp4Url = "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/compares/#{row.id}.mp4"
      fa_class = "<svg fill='#000000' height='20' viewBox='0 0 24 24' width='20'>
        <path d='M0 0h24v24H0z' fill='none'/>
        <path d='M10 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h5v2h2V1h-2v2zm0 15H5l5-6v6zm9-15h-5v2h5v13l-5-6v9h5c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2z'/>
        </svg>"
    else
      fa_class = "<svg width='20' height='20' viewBox='0 0 24 24' fill='none' stroke='#000000' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'>
      <polygon points='23 7 16 12 23 17 23 7'></polygon>
      <rect x='1' y='5' width='15' height='14' rx='2' ry='2'></rect>
      </svg>"

    return "<div class='gravatar-placeholder'><img class='gravatar' src='#{row.thumbnail_url}'><div class='type-icon-alignment'>#{fa_class}</div><div class='float-left'></div>
      <div class='username-id'>
      <a id='archive_url_link_#{row.id}' class='archive-title-color' data-ispublic='#{row.public}' data-status='#{row.status}' data-camera='#{row.camera_id}' data-id='#{row.id}' data-url='#{mp4Url}' data-thumbnail='#{row.thumbnail}' data-title='#{row.title}' data-from='#{renderFromDate(row, type, set, meta)}' data-to='#{renderToDate(row, type, set, meta)}' data-time=#{row.created_at} data-requester-by='#{row.requested_by}' data-autor='#{row.requester_name}' data-id='#{row.id}' data-type='#{row.type}'>#{row.title}</a>
      <br /><small class='blue'>From #{renderFromDate(row, type, set, meta)} to #{renderToDate(row, type, set, meta)}</small></div></div>
      <input id='txt_frames#{row.id}' type='hidden' value='#{row.frames}'>
      <input id='txt_duration#{row.id}' type='hidden' value='#{renderDuration(row, type, set, meta)}'>
      <input id='archive_embed_code#{row.id}' type='hidden' value='#{query_string}'/>#{archive_inputs}"

get_file_type = (extension) ->
  image_ext = ["jpg", "jpeg", "bmp", "gif", "png"]
  video_ext = ["mp4", "ogg", "webm", "avi", "flv", "wmv", "mov"]
  if image_ext.includes(extension)
    return "image"
  else if video_ext.includes(extension)
    return "video"
  else
    return "unknown"

gravatarName = (row, type, set, meta) ->
  main_div = $('<div>', {class: "main_div"})
  div_user = $('<div>', {class: "requester"})
  small = $("<small>")
  small.append(renderDate(row, type, set, meta))
  div_user.append("<label>On:</label>")
  div_user.append(small)
  div_user.append('<br>')
  if row.requester_email
    small = $("<small>")
    small.append(row.requester_name)
    div_user.append("<label>By:</label>")
    div_user.append(small)
    if row.status is 'Processing'
      div_user.append(" ( Processing )")
    else if row.status is 'Failed'
      div_user.append(" ( <span class='offlines'>Failed</span> )")
  else
    div_user.append("Deleted User")
  main_div.append(div_user)
  return main_div.html()

getHostName = (url) ->
  match = url.match(/:\/\/(www[0-9]?\.)?(.[^/:]+)/i)
  if match isnt null && match.length > 2 && typeof match[2] is 'string' && match[2].length > 0
    return match[2]
  else
    return null

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
  time = moment.tz(row.created_at*1000, Evercam.Camera.timezone)
  return "
    <div class='#{row.created_at} hide'>
    </div>\
    <span>#{moment(time).format('MMMM Do YYYY, HH:mm:ss')}</span>"

renderFromDate = (row, type, set, meta) ->
  getDates(row.from_date*1000)

renderToDate = (row, type, set, meta) ->
  getDates(row.to_date*1000)

renderDuration = (row, type, set, meta) ->
  if row.type is "compare"
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
  renderIsPublicPlayer(row.id, row.type, row.status, "#{row.public}", false)

renderIsPublicPlayer = (id, type, status, media_ispublic, add_label) ->
  if status is "Completed"
    if type is "url" || type is "compare"
      return ''
    else
      radio_label = ""
      enabled = ""
      if media_ispublic is "true"
        enabled = "checked"
      if add_label
        radio_label = "<span>Is public: </span>"

      return "<div id='siderbar'>
                <label class='label toggle title'>
                  #{radio_label}
                  <input type='checkbox' class='toggle_input_public toggle_input_public_clip' alt='#{id}' archive_type='#{type}' #{enabled} />
                  <div class='toggle-control'></div>
                </label>
              </div>"
  else
    return ''

renderStatus = (row, type, set, meta) ->
  if row.status is 'Processing'
    return "<img alt='Loading' style='margin-left: 20px;' src='/assets/loader3.gif'>"
  else
    return row.status

getDates = (times) ->
  offset =  $('#camera_time_offset').val()
  cameraOffset = parseInt(offset)/3600
  DateTime = new Date(moment.utc(times).format('MM/DD/YYYY, HH:mm:ss'))
  DateTime.setHours(DateTime.getHours() + (cameraOffset))
  Dateformateed =  format_time.formatDate(DateTime, 'd/m/y H:i')
  return Dateformateed

shareURL = ->
  $("#archives").on "click", ".share-archive", ->
    url = $(this).attr("play-url")
    copyToClipboard url

copyToClipboard = (text) ->
  dummy = document.createElement("input")
  document.body.appendChild(dummy)
  dummy.setAttribute('value', text)
  dummy.select()
  document.execCommand("copy")
  document.body.removeChild(dummy)
  Notification.show("URL copied!")
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
    if $("#txtCreateArchiveType").val() is "" && !has_snapshots
      $("#td-has-snapshot").removeClass("alert-info").addClass("alert-danger")
      return false

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
      $('#archive-modal').modal('hide')
      NProgress.done()
      $("#create_clip_button").removeAttr 'disabled'
      archives_table.ajax.reload (json) ->
        $('#archives-table').show()
        $("#no-archive").hide()
        formReset()
        setDate()
        $("#create_clip_button").removeAttr 'disabled'
      if $("#txtCreateArchiveType").val() isnt ""
        window.vjs_player_local.pause()
        $("#clip-create-message").show()

    settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      type: 'POST'
      url: "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/archives?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"
    $.ajax(settings)

GetSnapshotInfo = ->
  xhrRequestCheckSnapshot.abort() if xhrRequestCheckSnapshot
  duration = parseInt($("#to-date").val())
  date = $("#from-date").val().split('/')
  time = $('.timepicker-default').val().split(":")
  from = moment.tz("#{date[2]}-#{FormatNumTo2(date[1])}-#{FormatNumTo2(date[0])} #{FormatNumTo2(time[0])}:#{FormatNumTo2(time[1])}:00", "UTC")
  to = from.clone().minutes(from.minutes() + duration)

  data = {}
  data.api_id = Evercam.User.api_id
  data.api_key = Evercam.User.api_key
  data.from = from / 1000
  data.to = to / 1000
  data.limit = 3600
  data.page = 1

  onError = (jqXHR, status, error) ->
    false

  onSuccess = (response) ->
    $("#row-archive-has-snapshots").slideDown()
    if response == null || response.snapshots.length == 0
      has_snapshots = false
      $("#td-has-snapshot").removeClass("alert-info").addClass("alert-danger")
      $("#td-has-snapshot").html("There are no images for this time period.")
    else
      has_snapshots = true
      $("#td-has-snapshot").addClass("alert-info").removeClass("alert-danger")
      total_snapshots = parseInt(response.snapshots.length)
      total_seconds = Math.round(total_snapshots / 6)
      $("#td-has-snapshot").html("#{total_snapshots} snapshots (<b>#{total_seconds} seconds</b> @ <b>6 FPS</b>).")

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    contentType: "application/json charset=utf-8"
    type: 'GET'
    url: "#{Evercam.MEDIA_API_URL}cameras/#{Evercam.Camera.id}/recordings/snapshots"

  xhrRequestCheckSnapshot = $.ajax(settings)

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
  $("#txtCreateArchiveType").val("")
  $('#archive-modal').modal('hide')

playClip = ->
  $("#archives").on "click", ".play-clip", ->
    width = parseInt($(this).attr("data-width"))
    height = parseInt($(this).attr("data-height"))
    view_url = $(this).attr("play-url")
    window.open view_url, '_blank', "width=#{width}, Height=#{height}, scrollbars=0, resizable=0"

  $("#archives-box, #archives-table").on "click", ".download-animation", ->
    src_id = $(this).attr("data-download-target")
    NProgress.start()
    download("#{$("#{src_id}").val()}?api_key=#{Evercam.User.api_key}&api_id=#{Evercam.User.api_id}")
    setTimeout( ->
      NProgress.done()
    , 4000)

cancelForm = ->
  $('#archive-modal').on 'hidden.bs.modal', ->
    $("#clip-name").val("")
    $("#txtCreateArchiveType").val("")
    $("#row-archive-has-snapshots").slideUp()
    has_snapshots = false
    setDate()

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
      if control.attr("archive_type") is "compare"
        refresh_archive_table()
        hide_player_view()
        Notification.show("Compare deleted successfully.")
      else
        if data.message
          $(".bb-alert").removeClass("alert-info").addClass("alert-danger")
          Notification.show(data.message)
          NProgress.done()
        else
          refresh_archive_table()
          hide_player_view()
          Notification.show("Archive deleted successfully.")

    api_url = "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/archives/#{control.attr("archive_id")}?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"
    if control.attr("archive_type") is "compare"
      api_url = "#{Evercam.API_URL}cameras/#{control.attr("camera_id")}/compares/#{control.attr("archive_id")}?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"

    settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      type: 'DELETE'
      url: api_url
    $.ajax(settings)

hide_player_view = ->
  $(this).hide()
  update_request_url()
  $("#back-archives").hide()
  $("#back-button").hide()
  $("#toggle-tabs").show()
  $("#archives").css("width", "100%")
  $("#archives").css("margin-left", "0")
  $(".hide-add-button").show()
  $(".stackimage").addClass("stackimage-view")
  $(".stackimage").removeClass("stackimage-player")
  $("#archives-box-2").show()
  $("#camera-video-archive").hide()
  archive_js_player2.reset()
  $('#iframe_archive').prop('src', "")

  if is_list_view
    $("#archives-box").hide()
    $("#archives-table").show()
    $(".archive-tabs").show()
    $("#archives-tab").addClass("margin-top-15")
    if pagination
      $('#archives-table_paginate').show()
      $("#archives-table_info").show()

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
    setTimeout archives_table.ajax.reload, 20000

window.on_export_compare = ->
  archives_table.ajax.reload()
  $('#archives-table').show()
  $("#no-archive").hide()
  refreshDataTable()

modal_events = ->
  $("#archives").on "click", ".archive-title-color", ->
    id = $(this).attr("data-id")
    file_name = $(this).attr("data-file-name")
    file_type = $(this).attr("data-file-type")
    type = $(this).attr("data-type")
    status = $(this).attr("data-status")
    camera_id = $(this).attr("data-camera")
    media_url = $(this).attr("data-url")
    media_title = $(this).attr('data-title')
    media_autor = $(this).attr('data-autor')
    requested_by = $(this).attr("data-requester-by")
    media_from = $(this).attr('data-from')
    media_to = $(this).attr('data-to')
    media_thumbnail = $(this).attr('data-thumbnail')
    media_time = $(this).attr('data-time')
    media_ispublic = $(this).attr('data-ispublic')
    newTime = moment.tz(media_time * 1000, Evercam.Camera.timezone)
    $("#archive_delete_view").attr("camera_id", camera_id)
    $("#archive_delete_view").attr("archive_id", id)
    $("#archive_delete_view").attr("archive_type", type)

    if Evercam.Camera.has_edit_right || requested_by is Evercam.User.username
      $("#popup-delete-view").show()
    else
      $("#popup-delete-view").hide()

    if type is "compare"
      $("#archive-play video").attr("loop", "true")
    else
      $("#archive-play video").attr("loop", "false")

    if type is "clip" || type is "compare" || type is "url" || type is "file" || type is "edit"
      update_request_url(id)
      $('#archives-table_paginate').hide()
      $("#archives-table_info").hide()
      $("#toggle-tabs").hide()
      $("#archives-table").hide()
      $("#archives-box").show()
      $("#back-archives").show()
      $("#back-button").show()
      $("#camera-video-archive").show()
      $(".archive-tabs").hide()
      $(".hide-add-button").hide()
      $("#archives-box-2").hide()
      $(".stackimage").removeClass("stackimage-view")
      $(".stackimage").addClass("stackimage-player")
      $("#archives-tab").removeClass("margin-top-15")
      $('#txt_title').text(media_title)
      $('#archive-autor').html("Requested by: #{media_autor}</br>")
      $('#archive-dates').html("From #{media_from} to #{media_to}</br>")
      $('#archive-time-1').text("Created at #{moment(newTime).format('MMMM Do YYYY, H:mm:ss')}")
      $("#archives").css("width", "80%")
      $("#archives").css("margin-left", "10%")
      $("#txt-archive-type").val(type)
      $("#txt-archive-id").val(id)
      $("#txt-archive-title").val(media_title)
      $('.hide-add-button').hide()
      $('#player-buttons').empty()
      $('#player-buttons').append renderplayerbuttons(requested_by, id, camera_id, type, status, media_url, media_ispublic, file_name)
      calculateHeight()

      if type is "url"
        $("#archive-play").hide()
        $("#file_upload_viewer").hide()
        $("#archive-dates").hide()
        $("#iframe_archive").show()
        info_total = $("#back-button").height() + $("#info-archive").height() + $(".player-header").height() + $("#ul-nav-tab").height() + 52
        view_height = Metronic.getViewPort().height
        $("#iframe_archive").height(view_height - info_total)
        $('#iframe_archive').prop('src', convert_to_embed_url(media_url))
      else if type is "file" || type is "edit"
        $("#iframe_archive").hide()
        $('#archive-dates').html("Cloud Recordings #{media_from}</br>")
        if type is "file"
          $("#archive-dates").hide()

        if file_type is "image"
          $("#archive-play").hide()
          $("#file_upload_viewer").show()
          $("#file_upload_viewer").attr("src", media_url)
        else
          $("#archive-play").show()
          $("#file_upload_viewer").hide()
          load_player(media_thumbnail, media_url)
      else
        $("#file_upload_viewer").hide()
        $("#iframe_archive").hide()
        $("#archive-play").show()
        $("#archive-dates").show()
        load_player(media_thumbnail, media_url)

  $("#archives"). on "click", ".archive-title", ->
    id = $(this).attr("data-id")
    type = $(this).attr("data-type")
    media_url = $(this).attr("data-url")
    status = $(this).attr("data-status")
    ispublic = $(this).attr("data-ispublic")
    camera_id = $(this).attr("data-camera_id")
    file_name = $(this).attr("data-file-name")
    if ispublic is "true"
      $("#div_shares").show()
    else
      $("#div_shares").hide()
    if type isnt undefined
      update_request_url(id)
    query_string = $("#archive_embed_code#{id}").val()
    if type is "url"
      showArchiveUrlSaveButton()
    url = "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/compares/#{id}"
    mp4_url_value = "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/archives/#{id}"
    $("#txt-archive-id").val(id)
    $("#archive_gif_url").val("#{url}.gif")
    $("#archive_mp4_url").val("#{mp4_url_value}.mp4")
    $("#txt-archive-id").val(id)
    $("#social_media_url").val("#{media_url}")
    code = "<div id='evercam-compare'></div><script src='#{window.location.origin}/assets/evercam_compare.js' class='#{query_string} autoplay'></script>"
    $("#archive_embed_code").val(code)
    $("#div_frames").text($("#txt_frames#{id}").val())
    $("#div_duration").text($("#txt_duration#{id}").val())
    $("#txt_title").val($("#txtArchiveTitle#{id}").val())
    $("#media_title_title").val($("#archive_url_link_#{id}").text())

    share_url = "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/archives/#{id}.mp4"
    if type is "file" || type is "edit"
      share_url = "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/archives/#{file_name}"
    else if type is "compare"
      share_url = "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/compares/#{id}.mp4"

    $("#share-buttons-new a.facebook").attr("href", "http://www.facebook.com/sharer.php?u=#{share_url}")
    $("#share-buttons-new a.whatsapp").attr("href", "https://web.whatsapp.com/send?text=#{share_url}")
    $("#share-buttons-new a.linkedin").attr("href", "http://www.linkedin.com/shareArticle?url=#{share_url}&title=My photo&summary=This is a photo from evercam")
    $("#share-buttons-new a.twitter").attr("href", "http://twitter.com/share?url=#{share_url}&text=This is a photo from evercam&via=evrcm")

    if type isnt "compare"
      $("#row-compare").hide()
      $(".div-thumbnail").show()
      $("#row-embed-code").hide()
      $("#row-frames").show()
      $("#row-duration").show()
      $("#row-gif").hide()
      $("#archive-thumbnail").attr("src", $("#txtArchiveThumb#{id}").val())
      $("#row-mp4").show()

      if type is "file" || type is "edit"
        $("#row-frames").hide()
        $("#row-duration").hide()
        $("#row-mp4").hide()
    else
      $("#row-compare").html(window.compare_html)
      params = query_string.split(" ")
      bucket_url = "https://s3-eu-west-1.amazonaws.com/evercam-camera-assets/"
      before_image = "#{bucket_url}#{Evercam.Camera.id}/compares/#{params[3]}/start-#{params[1]}.jpg?#{Math.random()}"
      after_image = "#{bucket_url}#{Evercam.Camera.id}/compares/#{params[3]}/end-#{params[2]}.jpg?#{Math.random()}"
      $("#archive_compare_before").attr("src", before_image)
      $("#archive_compare_after").attr("src", after_image)
      $("#row-frames").hide()
      $("#div_shares").show()
      $("#row-duration").hide()
      $("#row-embed-code").show()
      $("#row-gif").show()
      $("#row-compare").show()
      $("#row-mp4").show()
      $(".div-thumbnail").hide()
      initCompare()

  $('#modal-archive-info').on 'hide.bs.modal', ->
    archive_js_player.pause()
    archive_js_player.reset()
    $("#row-compare").html("")
    imagesCompare = undefined
    update_request_url()

  $('#social-media-url-modal').on 'hide.bs.modal', ->
    reset_media_url_form()
    update_request_url()

update_request_url = (id) ->
  if id
    url = "#{Evercam.request.rootpath}/archives/#{id}"
  else
    url = "#{Evercam.request.rootpath}/archives"
  if $(".nav-tabs li.active a").html() is "Archives" && history.replaceState
    window.history.replaceState({}, '', url)

load_player = (media_thumbnail, media_url) ->
  archive_js_player2.poster(media_thumbnail)
  archive_js_player2.src([
    { type: "video/mp4", src: media_url }
  ])
  playPromise = archive_js_player2.play()
  if playPromise != undefined
    playPromise.then (_) ->
      console.log 'done'
    .catch (err) ->
      console.log 'error occured', err
    .done()

convert_to_embed_url = (media_url) ->
  split = media_url.split("/")
  if split.length > 4
    cut_size = split.length - 4
    media_url = split.slice(0, split.length - cut_size).join("/") + "/"
  media_url = media_url.replace("watch?v=", "embed/")
  media_url = media_url.replace("vimeo.com", "player.vimeo.com/video")
  return media_url

calculateHeight = ->
  info_total = $("#back-button").height() + $("#info-archive").height() + $(".player-header").height() + $("#ul-nav-tab").height() + 52
  view_height = Metronic.getViewPort().height
  total_height = view_height - info_total
  $("#iframe_archive").height(total_height)
  $("#file_upload_viewer").height(total_height)
  $("#archive-play").height(total_height)

handleResize = ->
  $(window).resize ->
    calculateHeight()

showArchiveUrlSaveButton = ->
  $("#update_archive").removeClass 'hide'
  $("#save_social_media_url").addClass 'hide'

hideArchiveUrlSaveButton = ->
  $("#save_social_media_url").removeClass 'hide'
  $("#update_archive").addClass 'hide'

showClipSaveButton = ->
  $("#edit_create_clip").removeClass 'hide'
  $("#edit_compare").addClass 'hide'

hideClipSaveButton = ->
  $("#edit_create_clip").addClass 'hide'
  $("#edit_compare").removeClass 'hide'

initCompare = ->
  imagesCompareElement = $('.archive-img-compare').imagesCompare()
  imagesCompare = imagesCompareElement.data('imagesCompare')
  events = imagesCompare.events()

  imagesCompare.on events.changed, (event) ->
    true

open_window = ->
  $(".type-link").on "click", ->
    type = $(this).attr("data-type")
    $("#row-archive-has-snapshots").slideUp()
    switch type
      when "local"
        $("#archive_create_caption").text("Create Local Recording Clip")
        $("#txtCreateArchiveType").val("true")
      when "cloud"
        $("#archive_create_caption").text("Create Cloud Recording Clip")
        GetSnapshotInfo()
      when "compare"
        $(".nav-tab-compare").tab('show')

init_fileupload = ->
  $("#file-upload").on "change", (e) ->
    lbl_old_val = $("#spn-upload-file-name").html()
    fileName = ''
    if $(this).files && $(this).files.length > 1
      fileName = ( $(this).getAttribute( 'data-multiple-caption' ) || '' ).replace( '{count}', $(this).files.length )
    else
      fileName = e.target.value.split( '\\' ).pop()

    if fileName
      $("#spn-upload-file-name").html(fileName)
    else
      $("#spn-upload-file-name").html(lbl_old_val)

  $("#upload-file-modal").on "hide.bs.modal", ->
    $("#file-upload-progress .bar").css("width", "0%")
    $("#file-upload-progress .bar").text("0%")
    $("#file-upload").val("")
    $("#spn-upload-file-name").html("Choose a file or drag it here.")
    $("#upload_file_title").val("")

  $("#start-file-upload").on "click", ->
    input = document.querySelector("#file-upload")
    if upload
      if uploadIsRunning
        upload.abort()
        $("#start-file-upload").val("Resume upload")
        uploadIsRunning = false
      else
        upload.start()
        $("#start-file-upload").val("Pause upload")
        uploadIsRunning = true
    else
      if $("#upload_file_title").val() is ""
        Notification.show("Title cannot be empty.")
        $(".bb-alert").removeClass("alert-info").addClass("alert-danger")
        return false
      if input.files.length is 0
        Notification.show("Choose file to upload.")
        $(".bb-alert").removeClass("alert-info").addClass("alert-danger")
        return false
      startUpload()

startUpload = ->
  file = document.querySelector("#file-upload").files[0]
  if !file
    return

  $("#start-file-upload").val("Pause upload")

  options =
    endpoint: Evercam.TUS_URL
    resume: true
    chunkSize: Infinity
    retryDelays: [0, 1000, 3000, 5000]
    onError: (error) ->
      $(".bb-alert").removeClass("alert-info").addClass("alert-danger")
      Notification.show("Failed because: #{error}")
      reset()
    onProgress: (bytesUploaded, bytesTotal) ->
      percentage = (bytesUploaded / bytesTotal * 100).toFixed(2)
      $("#file-upload-progress .bar").css("width", "#{percentage}%")
      $("#file-upload-progress .bar").text("#{parseInt(percentage)}%")
    onSuccess: ->
      save_upload_file(upload.url, upload.file.name)

  upload = new tus.Upload(file, options)
  upload.start()
  uploadIsRunning = true

reset = ->
  $("#start-file-upload").val("Start upload")
  $("#file-upload-progress .bar").css("width", "0%")
  $("#file-upload-progress .bar").text("0%")
  upload = null
  uploadIsRunning = false

save_upload_file = (file_url, filename) ->
  timespan = moment().utc() /1000

  $(".bb-alert").removeClass("alert-danger").addClass("alert-info")

  data =
    title: $("#upload_file_title").val()
    from_date: timespan
    to_date: timespan
    requested_by: Evercam.User.username
    type: "file"
    file_url: file_url
    file_extension: filename.slice (filename.lastIndexOf('.') - 1 >>> 0) + 2

  onError = (jqXHR, status, error) ->
    if jqXHR.status is 500
      Notification.show("Internal Server Error. Please contact to admin.")
    else
      Notification.show(jqXHR.responseJSON.message)
    $(".bb-alert").removeClass("alert-info").addClass("alert-danger")

  onSuccess = (data, status, jqXHR) ->
    $("#clip-create-message").show()
    archives_table.ajax.reload (json) ->
      $('#archives-table').show()
      $("#no-archive").hide()
      $("#upload-file-modal").modal("hide")
      reset()

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    type: 'POST'
    url: "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/archives?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"
  $.ajax(settings)

detect_validate_url = ->
  $("#social_media_url").on "keyup paste change", ->
    url = $("#social_media_url").val()
    domain = getHostName(url)
    setTimeout(->
      if url is "" or domain is null
        $("#icon-media-type").addClass("fa-link")
        $("#media_url_type").hide()
      else
        $("#media_url_type").attr("src", "https://favicon.yandex.net/favicon/#{getHostName(url)}")
        $("#media_url_type").show()
        $("#icon-media-type").removeClass("fa-link")
    , 200)

reset_media_url_form = ->
  $("#media_title_title").val("")
  $("#social_media_url").val("")
  $("#icon-media-type").addClass("fa-link")
  $("#media_url_type").hide()
  hideArchiveUrlSaveButton()

detect_url = (url, regex) ->
  patt = new RegExp(regex)
  patt.test(url)

handle_submenu = ->
  $("#archive-add").on "click", ->
    top = $(this).position().top
    archive_height = $("#archives").height()
    view_height = Metronic.getViewPort().height
    $(".triangle-right-border").css("top", "180px")
    $(".m-menu__submenu").css("top", top - 170)
    $(".m-menu__submenu").toggle( "slow")

  $(document).on 'mouseup', (evt) ->
    $(".m-menu__submenu").hide()

update_url = ->
  $("#update_archive").on "click", ->
    id = $("#txt-archive-id").val()
    if $("#media_title_title").val() is ""
      Notification.show("Title cannot be empty.")
      $(".bb-alert").removeClass("alert-info").addClass("alert-danger")
      return false
    if $("#social_media_url").val() is ""
      Notification.show("URL cannot be empty.")
      $(".bb-alert").removeClass("alert-info").addClass("alert-danger")
      return false
    NProgress.start()

    data =
      title: $("#media_title_title").val()
      url: $("#social_media_url").val()

    onError = (jqXHR, status, error) ->
      if jqXHR.status is 500
        Notification.show("Internal Server Error. Please contact to admin.")
      else
        Notification.show(jqXHR.responseJSON.message)
      $(".bb-alert").removeClass("alert-info").addClass("alert-danger")

    onSuccess = (data, status, jqXHR) ->
      archives_table.ajax.reload (json) ->
        $('#archives-table').show()
        $("#no-archive").hide()
        NProgress.done()
        $("#social-media-url-modal").modal("hide")
        reset_media_url_form()

    settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      type: 'PATCH'
      url: "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/archives/#{id}?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"
    sendAJAXRequest(settings)

update_archive = ->
  $("#edit-archive-title").on "click", ->
    elementValue = $("#txt_title").text();
    $("#txt_title").replaceWith('<input name="test" id="txt_title" type="text" value="' + elementValue + '">')
    $("#update-archive").show()
    $("#cancel-title").show()
    $("#edit-archive-title").hide()
    $("#txt_title").css("width", "50%")
    $("#txt_title").css("font-size", "22px")
    $("#update-archive i").css("font-size", "17px")
    $("#cancel-title i").css("font-size", "17px")

  $("#update-archive").on "click", ->
    id = $("#txt-archive-id").val()
    title = $("#txt_title").val()
    if title is ""
      Notification.show("Title cannot be empty.")
      $(".bb-alert").removeClass("alert-info").addClass("alert-danger")
      return false
    NProgress.start()

    data =
      title: title
      name: title

    onError = (jqXHR, status, error) ->
      if jqXHR.status is 500
        Notification.show("Internal Server Error. Please contact to admin.")
      else
        Notification.show(jqXHR.responseJSON.message)
      $(".bb-alert").removeClass("alert-info").addClass("alert-danger")
      NProgress.done()

    onSuccess = (data, status, jqXHR) ->
      archives_table.ajax.reload (json) ->
        $("#no-archive").hide()
        NProgress.done()
        formReset()
        $("#txt-archive-title").val(title)
        $("#update-archive").hide()
        $("#cancel-title").hide()
        $("#edit-archive-title").show()
        $("#edit-archive-title i").css("font-size", "17px")

    controller = "archives"
    if $("#txt-archive-type").val() is "compare"
      controller = "compares"

    settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      type: 'PATCH'
      url: "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/#{controller}/#{id}?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"
    sendAJAXRequest(settings)
    $("#txt_title").replaceWith('<strong id="txt_title">' + title + '</strong>')

  $("#cancel-title").on "click", ->
    value = $("#txt-archive-title").val()
    $("#txt_title").replaceWith('<strong id="txt_title">' + value + '</strong>')
    $("#update-archive").hide()
    $("#cancel-title").hide()
    $("#edit-archive-title").show()
    $("#edit-archive-title i").css("font-size", "17px")

save_media_url = ->
  $("#save_social_media_url").on "click", ->
    timespan = moment().utc() /1000
    $(".bb-alert").removeClass("alert-danger").addClass("alert-info")
    NProgress.start()

    data =
      title: $("#media_title_title").val()
      url: $("#social_media_url").val()
      from_date: timespan
      to_date: timespan
      requested_by: Evercam.User.username
      type: "url"

    onError = (jqXHR, status, error) ->
      if jqXHR.status is 500
        Notification.show("Internal Server Error. Please contact to admin.")
      else
        Notification.show(jqXHR.responseJSON.message)
      $(".bb-alert").removeClass("alert-info").addClass("alert-danger")

    onSuccess = (data, status, jqXHR) ->
      archives_table.ajax.reload (json) ->
        $('#archives-table').show()
        $("#no-archive").hide()
        NProgress.done()
        $("#social-media-url-modal").modal("hide")
        reset_media_url_form()

    settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      type: 'POST'
      url: "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/archives?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"
    $.ajax(settings)

showFiles = (files) ->
  $("#spn-upload-file-name").text if files.length > 1 then (input.getAttribute('data-multiple-caption') or '').replace('{count}', files.length) else files[0].name

filter_archives = ->
  $(".archive-tab-item").on "click", ->
    is_reload = false
    $(".archive-tab-item i").removeClass("fas").addClass("far")
    $(this).find("i").removeClass("far").addClass("fas")
    type = $(this).attr("data-val")
    if type is "compare"
      archives_table.column(2).visible false
      archives_table.column(3).visible true
    else
      if type is "url"
        archives_table.column(3).visible false
        archives_table.column(2).visible false
      else
        archives_table.column(3).visible true
        archives_table.column(2).visible true
    archives_table.column(5).search(type).draw()

tab_events = ->
  $('.nav-tab-archives').on 'shown.bs.tab', ->
    unless archive_id_from_url
      hide_player_view()
    archives_table.ajax.reload (json) ->
      $("#no-archive").hide()

  $(".nav-tab-archives").on "click", ->
    if $("#archives-box").css("display") is "block"
      hide_player_view()

window.initializeArchivesTab = ->
  getArchiveIdFromUrl()
  window.compare_html = $("#row-compare").html()
  if Evercam.User.username
    archive_js_player = videojs("archive_player")
    archive_js_player2 = videojs("archive-play")
  format_time = new DateFormatter()
  jQuery.fn.DataTable.ext.type.order['string-date-pre'] = (x) ->
    return moment(x, 'MMMM Do YYYY, H:mm:ss').format('X')
  $("#popup-delete-view").popbox
    open: "#open-delete-view"
    box: "#box-delete-view"
    arrow: "#arrow-delete-view"
    arrow_border: "#arrow-border-delete-view"
    close: "#closepopup-delete-view"

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
  open_window()
  init_fileupload()
  detect_validate_url()
  handle_submenu()
  save_media_url()
  filter_archives()
  update_archive()
  update_url()
  toggleView()
  makePublic()
  handleResize()
  tab_events()
  hover_thumbnail()
