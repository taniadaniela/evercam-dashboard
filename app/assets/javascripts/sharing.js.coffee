showError = (message) ->
   Notification.show(message)
   true

showFeedback = (message) ->
   Notification.show(message)
   true

sendAJAXRequest = (settings) ->
   token = $('meta[name="csrf-token"]')
   if token.size() > 0
      headers =
         "X-CSRF-Token": token.attr("content")
      settings.headers = headers
   jQuery.ajax(settings)
   true

addSharingCameraRow = (details) ->
   row  = $('<tr>')
   if details.type == "share_request"
      row.attr("share-request-id", details['share_id'])
   else
      row.attr("share-id", details['share_id'])

   cell = $('<td>', {class: "col-lg-4"})
   cell.append(document.createTextNode(" " + details['email']))
   if details.type == "share_request"
      suffix = $('<small>', {class: "blue"})
      suffix.text(" ...pending")
      cell.append(suffix)
   row.append(cell)

   cell   = $('<td>', {class: "col-lg-2"})
   div    = $('<div>', {class: "input-group"})
   select = $('<select>', {class: "form-control reveal", "show-class": "show-save"})
   select.focus(onPermissionsFocus)
   option = $('<option>', {value: "minimal"})
   if details.permissions != "full"
      option.attr("selected", "selected")
   option.text("Read Only")
   select.append(option)
   option = $('<option>', {value: "full"})
   if details.permissions == "full"
      option.attr("selected", "selected")
   option.text("Full Rights")
   select.append(option)
   div.append(select)
   cell.append(div)
   row.append(cell)

   cell = $('<td>', {class: "col-lg-2"})
   button = $('<button>', {class: "save show-save btn btn-primary"})
   button.text("Save")
   if details.type == "share"
      button.click(onSaveShareClicked)
   else
      button.click(onSaveShareRequestClicked)
   cell.append(button)
   row.append(cell)

   cell  = $('<td>', {class: "col-lg-2"})
   div   = $('<div>', {class: "form-group"})
   span = $('<span>')
   span.append($('<span>', {class: "glyphicon glyphicon-remove"}))
   if details.type == "share"
      span.addClass("delete-share-control")
      span.append($(document.createTextNode(" Remove")))
      span.click(onDeleteShareClicked)
      span.attr("share_id", details["share_id"])
   else
      span.addClass("delete-share-request-control")
      span.append($(document.createTextNode(" Revoke")))
      span.click(onDeleteShareRequestClicked)
      span.attr("email", details["email"])
   span.attr("camera_id", details["camera_id"])
   div.append(span)
   cell.append(div)
   row.append(cell)

   row.hide()
   $('#sharing_list_table tbody').append(row)
   row.fadeIn()
   true

onSetCameraAccessClicked = (event) ->
   event.preventDefault()
   selected = $('input[name=sharingOptionRadios]:checked').val()
   button   = $('#set_permissions_submit')
   cameraId = $('#sharing_tab_camera_id').val()

   data = {}
   switch selected
      when "public_discoverable"
         data.public = true
         data.discoverable = true
         $('.show-on-public').show()
         $('.show-on-private').hide()
      when "public_undiscoverable"
         data.public = true
         data.discoverable = false
         $('.show-on-public').show()
         $('.show-on-private').hide()
      else
         data.public = false
         data.discoverable = false
         $('.show-on-public').hide()
         $('.show-on-private').show()

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
   sendAJAXRequest(settings)
   true


onDeleteShareClicked = (event) ->
   event.preventDefault()
   control = $(event.currentTarget)
   row     = control.parent().parent().parent()
   data    =
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
   sendAJAXRequest(settings)
   true

onDeleteShareRequestClicked = (event) ->
   event.preventDefault()
   control = $(event.currentTarget)
   row     = control.parent().parent().parent()
   data    =
      camera_id: control.attr("camera_id")
      email: control.attr("email")
   onError = (jqXHR, status, error) ->
      showError("Delete of share request failed. Please contact support.")
      false
   onSuccess = (data, success, jqXHR) ->
      if data.success
         onComplete = ->
            row.remove()
         row.fadeOut('slow', onComplete)
      else
         showError("Delete of share request failed. Please contact support.")
      true
   settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      type: 'DELETE'
      url: '/share/request'
   sendAJAXRequest(settings)
   true

onAddSharingUserClicked = (event) ->
   event.preventDefault()
   emailAddress = $('#sharingUserEmail').val()
   if $('#sharingPermissionLevel').val() != "Full Rights"
      permissions = "minimal"
   else
      permissions = "full"
   onError = (jqXHR, status, error) ->
      showError("Failed to share camera.")
      false
   onSuccess = (data, status, jqXHR) ->
      if data.success
         if data.type == "share"
            addSharingCameraRow(data)
            showFeedback("Camera successfully shared with user")
         else
            data.type == "share_request"
            addSharingCameraRow(data)
            showFeedback("A notification email has been sent to the specified email address.")
         $('#sharingUserEmail').val("")

      else
         message = "Adding a camera share failed."
         switch data.code
            when "camera_not_found_error"
               message = "Unable to locate details for the camera in the system. Please refresh your view and try again."
            when "duplicate_share_error"
               message = "The camera has already been shared with the specified user."
            when "duplicate_share_request_error"
               message = "A share request for that email address already exists for this camera."
            when "share_grantor_not_found_error"
               message = "Unable to locate details for the user granting the share in the system."
            when "invalid_parameters"
               message = "Invalid rights specified for share creation request."
            else
               message = data.message
         showError(message)
      true
   createShare($('#sharing_tab_camera_id').val(), emailAddress, permissions, onSuccess, onError)
   true

onSaveShareClicked = (event) ->
   event.preventDefault()
   button  = $(this)
   row     = button.parent().parent()
   control = row.find('select')
   data    =
      permissions: control.val()
      camera_id: $('#ec_cam_id').text()
   onError = (jqXHR, status, error) ->
      showError("Update of share failed. Please contact support.")
      false
   onSuccess = (data, success, jqXHR) ->
      if data.success
         showFeedback("Share successfully updated.")
         button.fadeOut()
      else
         showError("Update of share failed. Please contact support.")
      true
   settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      type: 'PATCH'
      url: '/share/' + row.attr("share-id")
   sendAJAXRequest(settings)
   true

onSaveShareRequestClicked = (event) ->
   event.preventDefault()
   button  = $(this)
   row     = button.parent().parent()
   control = row.find('select')
   data    =
      permissions: control.val()
   onError = (jqXHR, status, error) ->
      showError("Update of share request failed. Please contact support.")
      false
   onSuccess = (data, success, jqXHR) ->
      if data.success
         showFeedback("Share request successfully updated.")
         button.fadeOut()
      else
         showError("Update of share request failed. Please contact support.")
      true
   settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      type: 'PATCH'
      url: '/share/request/' + row.attr("share-request-id")
   sendAJAXRequest(settings)
   true

createShare = (cameraID, email, permissions, onSuccess, onError) ->
  data =
    camera_id: cameraID
    email: email
    permissions: permissions

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    type: 'POST'
    url: '/share'
  sendAJAXRequest(settings)
  true

onPermissionsFocus = (event) ->
   $(this).parent().parent().parent().find("td:eq(2) button").fadeIn()
   true

onSharingOptionsClicked = (event) ->
   test = $(this).val();
   $("div.desc").hide();
   $("#Shares" + test).show();
   true

initializeSharingTab = ->
   $('#set_permissions_submit').click(onSetCameraAccessClicked)
   $('.delete-share-control').click(onDeleteShareClicked)
   $('.delete-share-request-control').click(onDeleteShareRequestClicked)
   $('#submit_share_button').click(onAddSharingUserClicked)
   $('.update-share-button').click(onSaveShareClicked)
   $('.update-share-request-button').click(onSaveShareRequestClicked)
   $('.save').hide()
   $('.reveal').focus(onPermissionsFocus);
   $("input[name$='sharingOptionRadios']").click(onSharingOptionsClicked);
   Notification.init(".bb-alert")
   true

if !window.Evercam
   window.Evercam = {}

window.Evercam.Share =
   initializeTab: initializeSharingTab
   createShare: createShare
