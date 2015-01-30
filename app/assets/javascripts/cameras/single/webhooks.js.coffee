showError = (message) ->
  Notification.show(message)

showFeedback = (message) ->
  Notification.show(message)

sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  $.ajax(settings)

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
  span.append($('<span>', {class: "remove"}))
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

onDeleteWebhookClicked = (event) ->
  event.preventDefault()
  control = $(event.currentTarget)
  row = control.closest('tr')
  data =
    camera_id: Evercam.Camera.id
    webhook_id: row.attr('webhook-id')
  onError = (jqXHR, status, error) ->
    showError("Deleting webhook failed. Please contact support.")
  onSuccess = (data, status, jqXHR) ->
    control.off()
    onComplete = ->
      row.remove()
    row.fadeOut('slow', onComplete)

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    type: 'DELETE'
    url: "/cameras/#{Evercam.Camera.id}/webhooks"
#    url: "/cameras/#{window.Evercam.Camera.id}/webhooks/#{row.attr('webhook-id')}"
  console.log data
  console.log settings
  console.log settings.url
  sendAJAXRequest(settings)

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
  createWebhook(webhookUrl, onSuccess, onError)

createWebhook = (url, onSuccess, onError) ->
  data =
    camera_id: Evercam.Camera.id
    url: url
    user_id: window.Evercam.User.username

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    type: 'POST'
    url: "/cameras/#{Evercam.Camera.id}/webhooks"
  sendAJAXRequest(settings)

onPermissionsFocus = (event) ->
  $(this).parent().parent().parent().find("td:eq(2) button").fadeIn()

window.initializeWebhookTab = ->
  $('.delete-webhook-control').click(onDeleteWebhookClicked)
  $('#submit_webhook_button').click(onAddWebhookUserClicked)
  $('#newWebhookUrl').keypress (e)->
    $('#submit_webhook_button').trigger('click') if e.which is 13
  $('.save').hide()
  $('.reveal').focus(onPermissionsFocus);
  Notification.init(".bb-alert")
