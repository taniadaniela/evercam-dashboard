window.showOfflineButton = ->
  if $.cookie("hide-offline-cameras")
    $("#offline-btn").prop("checked", true)
    $('.sub-menu, .dropdown-menu.scroll-menu, #camera-index').addClass('cam-active')
  $('#offline-btn').on 'click', (event) ->
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

slideToggleList = ->
  if $('.cameralist-height:visible').length == 0
    $('#hello .fa-caret-up').hide()
    $('#hello .fa-caret-down').show()
  else
    $('#hello .fa-caret-up').show()
    $('#hello .fa-caret-down').hide()

  if $('.status-report-submenu:visible').length == 0
    $('.status-report .fa-caret-up').hide()
    $('.status-report .fa-caret-down').show()
  else
    $('.status-report .fa-caret-up').show()
    $('.status-report .fa-caret-down').hide()

slideToggle = ->
  $('.camera-fadrop').click ->
    $('.cameralist-height').slideToggle 'slow', ->
      slideToggleList()
  $('.status-list').click ->
    $('.status-report-submenu').slideToggle 'slow', ->
      slideToggleList()

removeDropdown = ->
  $("#Intercom").on "click", ->
    $('#live_support').removeClass('open')

initSocket = ->
  Evercam.socket = new (Phoenix.Socket)(Evercam.websockets_url, {params: {api_id: Evercam.User.api_id, api_key: Evercam.User.api_key}})
  Evercam.socket.connect()
  Evercam.user_channel = Evercam.socket.channel("users:#{Evercam.User.username}")
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
  $('.cameralist-height').css 'max-height', $('.page-sidebar-menu').height() - 310

delay = do ->
  timer = 0
  (callback, ms) ->
    clearTimeout timer
    timer = setTimeout(callback, ms)
    return

sidebarScrollPosition = ->
  $(document).ready ->
    prev_scroll_position = $.cookie('prev_scroll_position')
    $('.cameralist-height').scrollTop prev_scroll_position

  $('.page-sidebar-menu .cameralist-height').scroll (event) ->
    scroll_positon = $('.cameralist-height').scrollTop()
    $.cookie 'prev_scroll_position', scroll_positon,
      expires: 7
      path: '/'

highlightActiveCamera = ->
  hrefs = $('.cameralist-height a')
  hrefs.each ->
    if $(this).data('camera-id') == Evercam.Camera.id
      $(this).parent().addClass('active-color')
    else
      $(this).parent().removeClass('active-color')

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
  sidebarScrollPosition()
  highlightActiveCamera()
  slideToggleList()
  $(window).resize ->
    delay (->
      handleCameraListHeight()
      return
    ), 500
    return
