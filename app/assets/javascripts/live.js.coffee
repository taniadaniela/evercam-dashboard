onSetCameraAccessClicked = (event) ->
	true

initializeLiveTab = ->
  $('#set_permissions_submit').click(onSetCameraAccessClicked)
  $('img.snap').each ->
    oldimg = $(this)
    $("<img />").attr('src', $(this).attr('data-proxy')).load () ->
      if not this.complete or this.naturalWidth is undefined or this.naturalWidth is 0
        console.log('camera offline')
      else
        oldimg.replaceWith($(this))
  true

if !window.Evercam
   window.Evercam = {}

window.Evercam.Live =
   initializeTab: initializeLiveTab