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

$ ->
  showOfflineButton()
  $('[data-toggle="tooltip"]').tooltip()

$(window).ready ->
  slideToggle()
  removeDropdown()
