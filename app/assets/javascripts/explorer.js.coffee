onSetCameraAccessClicked = (event) ->
	true

initializeExplorerTab = ->
   $('#set_permissions_submit').click(onSetCameraAccessClicked)
   true

if !window.Evercam
   window.Evercam = {}

window.Evercam.Explorer =
   initializeTab: initializeExplorerTab