onSetCameraAccessClicked = (event) ->
	true

initializeInfoTab = ->
   $('#set_permissions_submit').click(onSetCameraAccessClicked)
   true

if !window.Evercam
   window.Evercam = {}

window.Evercam.Info =
   initializeTab: initializeInfoTab