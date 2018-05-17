flashDetection = ->
  hasFlash = false
  try
    flash = new ActiveXObject('ShockwaveFlash.ShockwaveFlash')
    if flash
      hasFlash = true
  catch e
    if navigator.mimeTypes and navigator.mimeTypes['application/x-shockwave-flash'] != undefined and navigator.mimeTypes['application/x-shockwave-flash'].enabledPlugin
      hasFlash = true

  if hasFlash is true
    $('.flash-section .yes-flash').removeClass('hide')
    $('.flash-section .no-flash').addClass('hide')
    $('.flash-section .yes-flash').html '<span>Flash is installed on this browser.</span>'
  else
    $('.flash-section .no-flash').removeClass('hide')
    $('.flash-section .yes-flash').addClass('hide')
    $('.flash-section .no-flash').html '<span>Flash is not detected on this browser.</span>'

osAndBrowserDetection = ->
  userAgent = navigator.userAgent.toLowerCase()
  $('.os-section .os-info').html 'Running OS is: <span><b>' + navigator.platform + '</b></span>'
  $('.browser-section .browser-info').html 'Running browser is: <span><b>' + bowser.name + ' ' + bowser.version + '</b></span>'
  $('.javascipt-section .yes-javascript').html '<span>Javascript is enabled on this browser.</span>'

detectMediaUrlRequest = ->
  data = {}
  data.api_id = Evercam.User.api_id
  data.api_key = Evercam.User.api_key

  onError = (jqXHR, status, error) ->
    $('.media-resquest-section .yes-blocked').removeClass('hide')
    $('.media-resquest-section .no-blocked').addClass('hide')
  onSuccess = (response) ->
    $('.media-resquest-section .no-blocked').removeClass('hide')
    $('.media-resquest-section .yes-blocked').addClass('hide')

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    contentType: "application/json charset=utf-8"
    type: 'GET'
    url: "#{Evercam.MEDIA_API_URL}cameras?api_id#{Evercam.User.api_id}&api_key#{Evercam.User.api_key}"

window.initializeBrowserCompatiblity = ->
  flashDetection()
  osAndBrowserDetection()
  detectMediaUrlRequest()
