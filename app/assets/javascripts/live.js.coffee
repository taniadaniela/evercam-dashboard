onSetCameraAccessClicked = (event) ->
	true

initializeLiveTab = ->
   $('#set_permissions_submit').click(onSetCameraAccessClicked)
   true

if !window.Evercam
   window.Evercam = {}

window.Evercam.Live =
   initializeTab: initializeLiveTab