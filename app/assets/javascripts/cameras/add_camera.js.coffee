initNotification = ->
  Notification.init(".bb-alert");
  if notifyMessage
    Notification.show notifyMessage

sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = jQuery.ajax(settings)
  true

loadVendorModels = (vendor_id) ->
  $("#camera-model option").remove()
  $("#camera-model").append('<option value="">Loading...</option>');
  if vendor_id is ""
    return

  data = {}
  data.vendor_id = vendor_id
  data.limit = 400
  data.api_id = Evercam.User.api_id
  data.api_key = Evercam.User.api_key

  onError = (jqXHR, status, error) ->
    false

  onSuccess = (result, status, jqXHR) ->
    $("#camera-model option").remove()
    if result.models.length == 0
      $("#camera-model").append('<option value="">No Model Found</option>');
      return

    models = sortByKey(result.models, "name")
    for model in models
      jpg_url = if model.defaults.snapshots then model.defaults.snapshots.jpg else ''
      if jpg_url is "unknown"
        jpg_url = ""
      $("#camera-model").append("<option jpg-val='#{jpg_url}' value='#{model.id}'>#{model.name}</option>")
    $("#snapshot").val $("#camera-model").find(":selected").attr("jpg-val")

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    contentType: "application/json; charset=utf-8"
    type: 'GET'
    url: "#{Evercam.API_URL}models/search.json"

  sendAJAXRequest(settings)
  true

sortByKey = (array, key) ->
  array.sort (a, b) ->
    x = a[key]
    y = b[key]
    (if (x < y) then -1 else ((if (x > y) then 1 else 0)))

loadVendors = ->
  data = {}
  data.api_id = Evercam.User.api_id
  data.api_key = Evercam.User.api_key

  onError = (jqXHR, status, error) ->
    false

  onSuccess = (result, status, jqXHR) ->
    vendors = sortByKey(result.vendors, "name")
    for vendor in vendors
      $("#camera-vendor").append("<option value='#{vendor.id}'>#{vendor.name}</option>")

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    contentType: "application/json; charset=utf-8"
    type: 'GET'
    url: "#{Evercam.API_URL}vendors/search.json"

  sendAJAXRequest(settings)
  true

validate_hostname = (str) ->
  ValidIpAddressRegex = /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/
  ValidHostnameRegex = /^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$/
  ValidIpAddressRegex.test(str) or ValidHostnameRegex.test(str)

handleVendorModelEvents = ->
  $("#camera-vendor").on "change", ->
    loadVendorModels($(this).val())

  $(".camera-model").on "change", ->
    $("#snapshot").val $(this).find(":selected").attr("jpg-val")

onLoadPage = ->
  $(".settings").hide()
  #toggle the componenet with class msg_body
  $(".additional").click ->
    $(this).next(".settings").slideToggle 500

  $("#hide").click ->
    $("p").fadeOut()

  $("#reveal").click ->
    $(".this").fadeIn()

  $("#unreveal").click ->
    $(".this").fadeOut()

window.initializeAddCamera = ->
  Metronic.init()
  Layout.init()
  QuickSidebar.init()
  onLoadPage()
  $.validate()
  handleVendorModelEvents()
  initNotification()
  loadVendors()
