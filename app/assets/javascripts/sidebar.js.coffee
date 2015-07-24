handlePusherEventUser = ->
  if Evercam && Evercam.Pusher
    channel = Evercam.Pusher.subscribe(Evercam.User.username)
    channel.bind 'user_cameras_changed', (data) ->
      $('.sidebar-cameras-list').load '/v1/cameras/new .sidebar-cameras-list > *', ->
        hideOfflineCameras()

handleSidebarToggle = ->
  $('.toggle-sidebar').on 'click', (event) ->
    event.preventDefault()
    $(this).toggleClass('active')
    $('#cbp-spmenu-s1').toggleClass('cbp-spmenu-open')

hideOfflineCameras = ->
  total_offline_cameras = $(".sidebar-cameras-list li.sidebar-offline").length
  $("#total-offline-cameras").attr("data-original-title", "#{total_offline_cameras} Offline cameras")
  $("#total-offline-cameras sub").text(total_offline_cameras)
  if $.cookie("hide-offline-cameras")
    if total_offline_cameras is 0
      $("#total-offline-cameras").removeClass("hide").addClass("hide")
    else
      $("#total-offline-cameras").removeClass("hide")
    $(".sidebar-cameras-list li.sidebar-offline").removeClass("hide").addClass("hide")
  else
    $("#total-offline-cameras").removeClass("hide").addClass("hide")
    $(".sidebar-cameras-list li.sidebar-offline").removeClass("hide")

$ ->
  handleSidebarToggle()
  hideOfflineCameras()
  $('[data-toggle="tooltip"]').tooltip()

$(window).load ->
  handlePusherEventUser()
