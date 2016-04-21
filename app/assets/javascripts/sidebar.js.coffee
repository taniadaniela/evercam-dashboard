window.showOfflineButton = ->
  offline_cameras = $('.sub-menu.sidebar-cameras-list .sidebar-offline').length
  if offline_cameras > 0
    $('#siderbar').show()
  else
    $('#siderbar').hide()
  if $.cookie("hide-offline-cameras")
    $("#offline-btn").prop("checked", true)
    $("#offline-btn").addClass("active")
    $('.sub-menu, .dropdown-menu.scroll-menu, #camera-index').addClass('cam-active')
  $('#offline-btn').on 'click', (event) ->
    $(this).toggleClass('active')
    hide_cameras = $(this).prop("checked")
    if hide_cameras
      $.cookie("hide-offline-cameras", $(this).prop("checked"), { expires: 365, path: "/" })
      $('.sub-menu, .dropdown-menu.scroll-menu, #camera-index').toggleClass('cam-active')
    else
      $.removeCookie("hide-offline-cameras", { path: "/" })
      $('.sub-menu, .dropdown-menu.scroll-menu, #camera-index').toggleClass('cam-active')

nProgressCall = ->
  $('#hello > a').on 'click', ->
    NProgress.start()
  $('.cameralist-height > ul > li > a').on 'click', ->
    NProgress.start()
  $('.nprogCall').on 'click', ->
    NProgress.start()

slideToggle = ->
  $('.dev').click ->
    $('.developer-list').slideToggle()
  $('.seting').click ->
    $('.setting-list').slideToggle()
  $('.camera-fadrop').click ->
    $('.cameralist-height').slideToggle()

removeDropdown = ->
  $("#Intercom").on "click", ->
    $('#live_support').removeClass('open')

initSocket = ->
  Evercam.socket = new (Phoenix.Socket)(Evercam.websockets_url)
  Evercam.socket.connect()
  Evercam.user_channel = Evercam.socket.channel("users:#{Evercam.User.username}", {api_id: Evercam.User.api_id, api_key: Evercam.User.api_key})
  Evercam.user_channel.join()
  Evercam.user_channel.on 'camera-status-changed', (payload) ->
    updateCameraStatus(payload.camera_id, payload.status)

updateCameraStatus = (camera_id, status) ->
  if status
    $(".sidebar-cameras-list .camera-#{camera_id}").removeClass("sidebar-offline")
    $(".page-header.camera-#{camera_id} .camera-switch").removeClass("camera-offline")
    $(".page-content .camera-index.camera-#{camera_id}").removeClass("camera-offline")
    $(".page-content.camera-#{camera_id} #camera-details-panel .status").parent().html('<div class="status green">Online</div>')
  else
    $(".sidebar-cameras-list .camera-#{camera_id}").addClass("sidebar-offline")
    $(".page-header.camera-#{camera_id} .camera-switch").addClass("camera-offline")
    $(".page-content .camera-index.camera-#{camera_id}").addClass("camera-offline")
    $(".page-content.camera-#{camera_id} #camera-details-panel .status").parent().html('<div class="status red">Offline</div>')

handleToggle = ->
  value = $('#controller').val()
  if value is 'users' || value is 'apps'
    $('.setting-list').show()
  else if value is 'widgets' || value is 'pages'
    $('.developer-list').show()

handleCameraListHeight = ->
  $('.cameralist-height').css 'max-height', $('.page-sidebar-menu').height() - 395

delay = do ->
  timer = 0
  (callback, ms) ->
    clearTimeout timer
    timer = setTimeout(callback, ms)
    return

$ ->
  initSocket()
  showOfflineButton()
  $('[data-toggle="tooltip"]').tooltip()

$(window).ready ->
  nProgressCall()
  slideToggle()
  removeDropdown()
  handleToggle()
  handleCameraListHeight()
  $(window).resize ->
    delay (->
      handleCameraListHeight()
      return
    ), 500
    return
