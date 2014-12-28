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

addWebhookRow = (details) ->
  row = $('<tr>')
  row.attr("webhook-id", details['id'])
  link = document.createElement('a');
  link.appendChild(document.createTextNode(details['url']))
  link.href = details['url']
  link.target = '_blank'
  cell = $('<td>', {class: "col-lg-8"})
  cell.append(link)
  row.append(cell)

  cell = $('<td>', {class: "col-lg-2"})
  div = $('<div>', {class: "form-group"})
  span = $('<span>')
  span.append($('<span>', {class: "glyphicon glyphicon-remove"}))
  span.addClass("delete-webhook-control")
  span.append($(document.createTextNode(" Remove")))
  span.click(onDeleteWebhookClicked)
  span.attr("webhook_id", details["webhook_id"])
  span.attr("camera_id", details["camera_id"])
  div.append(span)
  cell.append(div)
  row.append(cell)

  row.hide()
  $('#webhook_list_table tbody').append(row)
  row.fadeIn()
  true

onDeleteWebhookClicked = (event) ->
  event.preventDefault()
  control = $(event.currentTarget)
  row = control.parent().parent().parent()
  data =
    camera_id: control.attr("camera_id")
    webhook_id: control.attr("webhook_id")
  onError = (jqXHR, status, error) ->
    showError("Deleting webhook failed. Please contact support.")
    false
  onSuccess = (data, status, jqXHR) ->
    control.off()
    onComplete = ->
      row.remove()
    row.fadeOut('slow', onComplete)
    true

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    type: 'DELETE'
    url: '/webhooks/' + row.attr("webhook-id")
  sendAJAXRequest(settings)
  true

onAddWebhookUserClicked = (event) ->
  event.preventDefault()
  webhookUrl = $('#newWebhookUrl').val()
  if webhookUrl == ''
    showError("Webhook URL can't be blank.")
    return
  onError = (jqXHR, status, error) ->
    showError("Failed to add new webhook to the camera.")
    false
  onSuccess = (data, status, jqXHR) ->
    if data.success
      addWebhookRow(data)
      showFeedback("Webhook successfully added to the camera")
      $('#newWebhookUrl').val("")
    else
      showError("Failed to add new webhook to the camera. The provided url is not valid.")
    true
  createWebhook(Evercam.Camera.id, webhookUrl, onSuccess, onError)
  true

createWebhook = (cameraID, url, onSuccess, onError) ->
  data =
    camera_id: cameraID
    url: url
    user_id: window.Evercam.User.username

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    type: 'POST'
    url: "/webhooks"
  sendAJAXRequest(settings)
  true

onPermissionsFocus = (event) ->
  $(this).parent().parent().parent().find("td:eq(2) button").fadeIn()
  true

window.initializeWebhookTab = ->
  $('.delete-webhook-control').click(onDeleteWebhookClicked)
  $('#submit_webhook_button').click(onAddWebhookUserClicked)
  $('#newWebhookUrl').keypress (e)->
    $('#submit_webhook_button').trigger('click') if e.which is 13
  $('.save').hide()
  $('.reveal').focus(onPermissionsFocus);
  Notification.init(".bb-alert")
  true
