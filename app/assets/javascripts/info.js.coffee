onSetCameraAccessClicked = (event) ->
	true

showSharingTab = ->
  $('.nav-tabs a[href=#sharing]').tab('show');
  setTimeout(->
    scrollTo(0, 0)
  10);

initializeInfoTab = ->
   $('#set_permissions_submit').click(onSetCameraAccessClicked)
   $('.open-sharing').click(showSharingTab)
   true

if !window.Evercam
   window.Evercam = {}

window.Evercam.Info =
   initializeTab: initializeInfoTab