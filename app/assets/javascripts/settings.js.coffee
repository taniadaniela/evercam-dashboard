onSetCameraAccessClicked = (event) ->
	true

initializeSettingsTab = ->
   $('#set_permissions_submit').click(onSetCameraAccessClicked)
   true

if !window.Evercam
   window.Evercam = {}

window.Evercam.Settings =
   initializeTab: initializeSettingsTab

jQuery ->
  $('div').tooltip();

