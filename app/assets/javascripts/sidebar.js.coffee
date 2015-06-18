handlePusherEventUser = ->
  if Evercam && Evercam.Pusher
    channel = Evercam.Pusher.subscribe(Evercam.User.username)
    channel.bind 'user_cameras_changed', (data) ->
      $('.sidebar-cameras-list').load '/v1/cameras/new .sidebar-cameras-list > *'

handleSidebarToggle = ->
  $('.toggle-sidebar').on 'click', (event) ->
    event.preventDefault()
    $(this).toggleClass('active')
    $('#cbp-spmenu-s1').toggleClass('cbp-spmenu-open')

showOfflineCameras = ->
  if $.cookie("show-offline-cameras")
    $(".sidebar-cameras-list li.sidebar-offline").removeClass("hide")
  else
    $(".sidebar-cameras-list li.sidebar-offline").addClass("hide")

$ ->
  handleSidebarToggle()
  showOfflineCameras()

$(window).load ->
  handlePusherEventUser()
