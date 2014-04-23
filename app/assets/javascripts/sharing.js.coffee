showError = (message) ->
   bootbox.alert(message)
   true

showFeedback = (message) ->
   bootbox.alert(message)
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
   cell = $('<td>')
   cell.text(details['email'])
   row.append(cell)

   cell   = $('<td>')
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

   cell = $('<td>')
   div  = $('<div>', {class: "form-group"})
   div.append($('<div>', {class: "col-sm-8"}))
   cell.append(div)
   row.append(cell)

   cell  = $('<td>')
   div   = $('<div>', {class: "form-group"})
   inner = $('<div>', {class: "col-sm-8"})
   span  = $('<span>', {class: "delete-share-control"})
   span.attr("camera_id", details["camera_id"])
   span.attr("share_id", details["share_id"])
   span.append($('<span>', {class: "glyphicon glyphicon-remove"}))
   span.append($(document.createTextNode(" Remove User")))
   span.click(onDeleteShareClicked)
   inner.append(span)
   div.append(inner)
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
   sendAJAXRequest(settings)
   true

onAddSharingUserClicked = (event) ->
   event.preventDefault()
   emailAddress = $('#sharingUserEmail').val()
   if $('#sharingPermissionLevel').val() != "Full Rights"
      permissions = "minimal"
   else
      permissions = "full"
   data =
      camera_id: $('#sharing_tab_camera_id').val()
      email:     $('#sharingUserEmail').val()
      permissions: permissions
   onError = (jqXHR, status, error) ->
      showError("Add camera shared failed. Please contact support.")
      false
   onSuccess = (data, status, jqXHR) ->
      if data.success
         addSharingCameraRow(data)
         $('#sharingUserEmail').val("")
      else
         showError("Add camera shared failed. Please contact support.")
      true

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
   $('#submit_share_button').click(onAddSharingUserClicked)
   true

if !window.Evercam
   window.Evercam = {}

window.Evercam.Share =
   initializeTab: initializeSharingTab

