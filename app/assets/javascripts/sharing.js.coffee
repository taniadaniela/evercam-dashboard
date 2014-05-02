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
   cell = $('<td>', {class: "col-lg-4"})
   cell.append($('<span>', {class: "glyphicon glyphicon-user"}))
   cell.append(document.createTextNode(" " + details['email']))
   if details.type == "share_request"
      suffix = $('<small>', {class: "blue"})
      suffix.text(" ...pending")
      cell.append(suffix)
   row.append(cell)

   cell   = $('<td>', {class: "col-lg-2"})
   div    = $('<div>', {class: "input-group input-group-sm"})
   select = $('<select>', {class: "form-control"})
   option = $('<option>')
   if details.permissions != "full"
      option.attr("selected", "selected")
   option.text("Read Only")
   select.append(option)
   option = $('<option>')
   if details.permissions == "full"
      option.attr("selected", "selected")
   option.text("Full Rights")
   select.append(option)
   div.append(select)
   cell.append(div)
   row.append(cell)

   cell = $('<td>', {class: "col-lg-2"})
   div  = $('<div>', {class: "form-group"})
   div.append($('<div>', {class: "col-sm-8"}))
   cell.append(div)
   row.append(cell)

   cell  = $('<td>', {class: "col-lg-2"})
   div   = $('<div>', {class: "form-group"})
   span = $('<span>')
   span.append($('<span>', {class: "glyphicon glyphicon-remove"}))
   if details.type == "share"
      span.addClass("delete-share-control")
      span.append($(document.createTextNode(" Remove User")))
      span.click(onDeleteShareClicked)
      span.attr("share_id", details["share_id"])
   else
      span.addClass("delete-share-request-control")
      span.append($(document.createTextNode(" Revoke Request")))
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
      showError("Add camera shared failed. Ensure the email address is correct and that the email has an Evercam account associated with it.")
      false
   onSuccess = (data, status, jqXHR) ->
      if data.success
         if data.type == "share"
            addSharingCameraRow(data)
            showFeedback("Camera successfully shared with User")
         else
            data.type == "share_request"
            addSharingCameraRow(data)
            showFeedback("A notification email has been dispatched to the specified email address.")
         $('#sharingUserEmail').val("")

      else
         showError("Adding a User failed. Please check the User's email address.")
      true
   createShare($('#sharing_tab_camera_id').val(), emailAddress, permissions, onSuccess, onError)
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


initializeSharingTab = ->
   $('#set_permissions_submit').click(onSetCameraAccessClicked)
   $('.delete-share-control').click(onDeleteShareClicked)
   $('.delete-share-request-control').click(onDeleteShareRequestClicked)
   $('#submit_share_button').click(onAddSharingUserClicked)
   true

if !window.Evercam
   window.Evercam = {}

window.Evercam.Share =
   initializeTab: initializeSharingTab
   createShare: createShare
