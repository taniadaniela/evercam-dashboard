window.updateSidebar = ->
  data =
    user_id: Evercam.User.id
    api_id: Evercam.User.api_id
    api_key: Evercam.User.api_key
    include_shared: true

  onSuccess = (data, status, jqXHR) ->
    renderSidebar(data.cameras)
  settings =
    cache: false
    data: data
    dataType: 'json'
    success: onSuccess
    type: 'GET'
    url: "#{Evercam.API_URL}cameras.json"
  sendAJAXRequest(settings)

renderSidebar = (cameras) ->
  sidebar = ""
  for camera in cameras
    classes = if camera.is_online then "" else "sidebar-offline"
    row = """
    <li class="sub-menu-item #{classes}">
      <a href="/v1/cameras/#{camera.id}">#{camera.name}</a>
      <li class="sub-menu-item #{sidebar-offline}">
      <i class="red main-sidebar fa fa-chain-broken"></i>
      </li>
    </li>\n
    """
    sidebar = sidebar + row
  $(".sidebar-cameras-list").html(sidebar)

window.showOfflineButton = ->
  offline_cameras = $('.sub-menu.sidebar-cameras-list .sidebar-offline').length
  if offline_cameras > 0
    $('#siderbar').show()
  else
    $('#siderbar').hide()
  if $.cookie("hide-offline-cameras")
    $("#offline-btn").prop("checked",true)
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

slidetoggel = ->
  $('.dev').click ->
    $('.developer-list').slideToggle()
    return
  $('.seting').click ->
    $('.setting-list').slideToggle()
    return
  $('#hello').click ->
    $('.cameralist-height').slideToggle()
    return
  return

RemoveDropdown = ->
  $("#Intercom").on "click", ->
    $('#live_support').removeClass('open')

handlePusherEventUser = ->
  if Evercam && Evercam.Pusher
    channel = Evercam.Pusher.subscribe(Evercam.User.username)
    channel.bind 'user_cameras_changed', (data) ->
      updateSidebar()

handleSidebarToggle = ->
  $('.toggle-sidebar').on 'click', (event) ->
    event.preventDefault()
    $(this).toggleClass('active')
    $('#cbp-spmenu-s1').toggleClass('cbp-spmenu-open')

$ ->
  showOfflineButton()
  handleSidebarToggle()
  $('[data-toggle="tooltip"]').tooltip()

$(window).load ->
  slidetoggel()
  handlePusherEventUser()
  RemoveDropdown()
  

