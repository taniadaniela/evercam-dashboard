onSetCameraAccessClicked = (event) ->
   event.preventDefault()
   selected = $('input[name=optionsRadios]:checked').val()
   button   = $('#set_permissions_submit')
   cameraId = $('#camera_id').val()

   data = {}
   switch selected
      when "public_discoverable"
         data.public = true
         data.discoverable = true
      when "public_undiscoverable"
         data.public = true
         data.discoverable = false
      else
         data.public = false
         data.discoverable = false

   onError = (jqXHR, status, error) ->
      alert("Update of camera permissions failed. Please contact support.")
      button.removeAttr('disabled')
      false

   onSuccess = (data, status, jqXHR) ->
      alert("Camera permissions successfully updated.")
      button.removeAttr('disabled')
      true

   settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      type: 'POST'
      url: '/share/camera/' + cameraId

   button.attr('disabled', 'disabled')
   jQuery.ajax(settings)
   true

initializeSharingTab = ->
   $('#set_permissions_submit').click(onSetCameraAccessClicked)
   true

if !window.Evercam
   window.Evercam = {}

window.Evercam.Share =
   initializeTab: initializeSharingTab
