updateCode = () ->
  camera = $('#widget-camera').val()
  refresh = $('#widget-refresh-rate').val()
  width = $('#widget-camera-width').val()
  url = 'https://dashboard.evercam.io'
  #url = 'http://local.evercam.io:3000'
  camera_name = $('#widget-camera option:selected').text()
  offline = camera_name.indexOf('(Offline)') != -1
  priv = if camera_name.indexOf('(Private)') == -1 then 'false' else 'true'
  priv2 = if camera_name.indexOf('(Private)') == -1 then '' else 'private.'
  console.log(priv)
  baseText = "<div id='ec-container' style='width: "+width+"px'></div>
      <script src='"+url+"/live.view.widget.js?refresh="+refresh+"&camera="+camera+"&private="+priv+"' async></script>"
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
