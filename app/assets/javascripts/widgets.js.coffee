updateCode = () ->
  camera = $('#widget-camera').val()
  refresh = $('#widget-refresh-rate').val()
  width = $('#widget-camera-width').val()
  pre_auth = $('#widget-authenticate').val()
  console.log 'pre_auth'
  console.log pre_auth
  url = window.location.origin
  camera_name = $('#widget-camera option:selected').text()
  offline = camera_name.indexOf('(Offline)') != -1
  priv = if camera_name.indexOf('(Private)') == -1 then 'false' else 'true'
  api_credentials = if pre_auth == 'true' then "&api_id=#{window.api_credentials.api_id}&api_key=#{window.api_credentials.api_key}" else ''
  console.log api_credentials
  baseText = "<div id='ec-container' style='width: #{width}px'></div>
    <script src='#{url}/live.view.widget.js?refresh=#{refresh}&camera=#{camera}&private=#{priv}#{api_credentials}' async></script>"
  $('#code').text(baseText)
  document.removeEventListener("visibilitychange", window.ec_vis_handler, false);
  clearTimeout(window.ec_watcher) if window.ec_watcher?
  $('.preview').html(baseText) unless offline
  true

$ ->
  updateCode()
  $('#widget-camera-width').change(updateCode)
  $('#widget-refresh-rate').change(updateCode)
  $('#widget-camera').change(updateCode)
  $('#widget-authenticate').change(updateCode)
