updateCode = () ->
  camera = $('#widget-camera').val()
  refresh = $('#widget-refresh-rate').val()
  width = $('#widget-camera-width').val()
  url = 'https://dashboard.evercam.io'
  #url = 'http://local.evercam.io:3000'
  baseText = "<div id='ec-container' style='width: "+width+"px'></div>
      <script src='"+url+"/live.view.widget.js?refresh="+refresh+"&camera="+camera+"' async></script>"
  $('#code').text(baseText)
  document.removeEventListener("visibilitychange", window.ec_vis_handler, false);
  clearTimeout(window.ec_watcher) if window.ec_watcher?
  $('.preview').html(baseText)
  true

$ ->
  updateCode()
  $('#widget-camera-width').change(updateCode)
  $('#widget-refresh-rate').change(updateCode)
  $('#widget-camera').change(updateCode)
