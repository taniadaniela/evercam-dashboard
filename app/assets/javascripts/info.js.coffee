onSetCameraAccessClicked = (event) ->
	true

showSharingTab = ->
  $('.nav-tabs a[href=#sharing]').tab('show');
  setTimeout(->
    scrollTo(0, 0)
  10);

onChangeOwnerButtonClicked = (event) ->
   event .preventDefault()
   showChangeOwnerDialog(true)
   true

setChangeOwnerDialogError = (message) ->
   $('#change_owner_error').text(message)
   if message == ''
      $('#change_owner_error').hide()
   else
      $('#change_owner_error').show()
   true

onChangeOwnerSubmitClicked = (event) ->
   event.preventDefault()
   field  = $('#new_owner_email')
   if field.val() != ''
      dialog = $('#change_owner_dialog')
      dialog.modal('hide')
      setChangeOwnerDialogError("")
      onError = (jqXHR, status, error) ->
         setChangeOwnerDialogError("An error occurred transferring ownership of this camera. Please try again and, if the problem persists, contact support.")
         showChangeOwnerDialog(false)
         true
      onSuccess = (data, status, jqXHR) ->
         if data.success
            alert("Camera ownership has been successfully transferred.")
            location = window.location
            location.assign(location.protocol + "//" + location.host)
         else
            setChangeOwnerDialogError(data.message)
            showChangeOwnerDialog(false)            
         true
      data =
         camera_id: $('#change_owner_camera_id').val()
         email: field.val()
      settings =
         cache: false
         data: data
         error: onError
         success: onSuccess
         url: '/cameras/transfer'
      jQuery.ajax(settings)
   true

showChangeOwnerDialog = (clear) ->
   if clear
      $('#new_owner_email').val("")
      $('#change_owner_error').hide()
   $('#change_owner_dialog').modal('show')
   onComplete = ->
      $('#new_owner_email').select();
   setTimeout(onComplete, 200);
   true

initializeInfoTab = ->
   $('#set_permissions_submit').click(onSetCameraAccessClicked)
   $('.open-sharing').click(showSharingTab)
   true

if !window.Evercam
   window.Evercam = {}

window.Evercam.Info =
   initializeTab: initializeInfoTab