showError = (message) ->
   alert(message)
   true

showFeedback = (message) ->
   alert(message)
   true

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
      showError("Update of camera permissions failed. Please contact support.")
      button.removeAttr('disabled')
      false

   onSuccess = (data, status, jqXHR) ->
      if data.success
         showFeedback("Camera permissions successfully updated.")
      else
         showError("Update of camera permissions failed. Please contact support.")
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

onDeleteShareClicked = (event) ->
   event.preventDefault()
   control  = $(event.currentTarget)
   row      = control.parent().parent().parent().parent()
   data     =
      camera_id: control.attr("camera_id")
      share_id: control.attr("share_id")
   onError = (jqXHR, status, error) ->
      showError("Delete of camera shared failed. Please contact support.")
      false
   onSuccess = (data, status, jqXHR) ->
      if data.success
         onComplete = ->
            row.remove()
         row.fadeOut('slow', onComplete)
      else
         showError("Delete of camera shared failed. Please contact support.")
      true

   settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      type: 'DELETE'
      url: '/share'
   jQuery.ajax(settings)
   true

initializeSharingTab = ->
   $('#set_permissions_submit').click(onSetCameraAccessClicked)
   $('.delete-share-control').click(onDeleteShareClicked)
   true

if !window.Evercam
   window.Evercam = {}

window.Evercam.Share =
   initializeTab: initializeSharingTab
