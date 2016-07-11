vandor_urls = []

initNotification = ->
  Notification.init(".bb-alert")
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

loadVendorModels = (vendor_id, stroke_key_up) ->
  $("#camera-model option").remove()
  $("#camera-model").append('<option value="">Loading...</option>')
  if vendor_id is ""
    $("#camera-model option").remove()
    $("#camera-model").append('<option value="">Select Camera Model</option>')
    $("#snapshot").val("")
    $("#snapshot-readonly").val("")
    $("#snapshot").removeClass("hide")
    $("#snapshot-readonly").addClass("hide")
    $("#vendor-image").addClass("hide")
    vandor_urls = []
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
      $("#camera-model").append('<option value="">No Model Found</option>')
      return

    models = sortByKey(result.models, "name")
    urls = []
    vandor_urls = []
    for model in models
      selected = if model.id is $("#last-selected-model").val() then 'selected="selected"' else ''
      jpg_url = if model.defaults.snapshots then model.defaults.snapshots.jpg else ''
      jpg_url = cleanAndSetJpegUrl(jpg_url)
      if jpg_url is "unknown"
        jpg_url = ""
      else
        if jpg_url isnt "" && urls.indexOf(jpg_url) is -1
          urls.push(jpg_url)
          vandor_urls.push(model)
      if selected is '' && model.name.toLowerCase().indexOf('default') isnt -1
        $("#camera-model").prepend("<option jpg-val='#{jpg_url}' value='#{model.id}' selected='selected'>#{model.name}</option>")
      else if model.name.toLowerCase().indexOf('other') isnt -1
        $("#camera-model").prepend("<option jpg-val='#{jpg_url}' value='#{model.id}' selected='selected'>#{model.name} - Custom URL</option>")
      else
        $("#camera-model").append("<option jpg-val='#{jpg_url}' value='#{model.id}' #{selected}>#{model.name}</option>")
    if $("#last-selected-model").val() is ''
      if model.id isnt "other_default"
        $("#snapshot").val $("#camera-model").find(":selected").attr("jpg-val")
        $("#snapshot-readonly").val $("#camera-model").find(":selected").attr("jpg-val")
        $("#snapshot").addClass("hide")
        $("#snapshot-readonly").removeClass("hide")
        $(".snap-end").addClass("hide")
      else
        $("#snapshot").val("") if !stroke_key_up
        $("#snapshot-readonly").val("")
        $("#snapshot").removeClass("hide")
        $("#snapshot-readonly").addClass("hide")
        $(".snap-end").removeClass("hide")
    $("#last-selected-model").val('')

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    contentType: "application/json; charset=utf-8"
    type: 'GET'
    url: "#{Evercam.API_URL}models"

  sendAJAXRequest(settings)
  true

cleanAndSetJpegUrl = (jpeg_url) ->
  if jpeg_url.indexOf('/') == 0
    jpeg_url = jpeg_url.substr(1)
  return jpeg_url

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
    $("#camera-vendor option").remove()

    for vendor in vendors
      selected = ''
      if vendor.id is $("#last-selected-vendor").val()
        selected = 'selected="selected"'
        $("#vendor-image").attr("src", vendor.logo)
        $("#vendor-image").removeClass("hide")
        loadVendorModels(vendor.id)
        $("#last-selected-vendor").val('')
      if vendor.id is "other"
        $("#camera-vendor").prepend("<option data-val='#{vendor.logo}' value='#{vendor.id}' #{selected}>#{vendor.name} - Custom URL</option>")
      else
        $("#camera-vendor").append("<option data-val='#{vendor.logo}' value='#{vendor.id}' #{selected}>#{vendor.name}</option>")
    $("#camera-vendor").prepend('<option value="">Select Camera Vendor</option>')
    $('#camera-vendor').select2()
      #placeholder: 'Select Camera'
      #templateResult: format
      #templateSelection: format
      #escapeMarkup: (m) ->
      #  m
    $(".select2-container").addClass("form-control")
    $(".select2-container").css("width", "auto")

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    contentType: "application/json; charset=utf-8"
    type: 'GET'
    url: "#{Evercam.API_URL}vendors"

  sendAJAXRequest(settings)
  true

format = (state) ->
  if !state.id
    return state.text
  if state.id == '0'
    return state.text
  if state.element.attributes[0].nodeValue == 'null'
    '<table style=\'width:100%;\'><tr><td><img style=\'width:35px;\' class=\'flag\' src=\'assets/img/cam-img-small.jpg\'/>&nbsp;&nbsp;' + state.text + '</td></tr></table>'
  else
    '<table style=\'width:100%;\'><tr><td><img style=\'width:35px;\' class=\'flag\' src=\'' + state.element.attributes[0].nodeValue + '\'/>&nbsp;&nbsp;' + state.text + '</td></tr></table>'

validate_hostname = (str) ->
  ValidIpAddressRegex = /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/
  ValidHostnameRegex = /^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$/
  ValidIpAddressRegex.test(str) or ValidHostnameRegex.test(str)

handleVendorModelEvents = ->
  $("#camera-vendor").on "change", ->
    $("#vendor-image").attr("src", $(this).find(":selected").attr("data-val"))
    $("#vendor-image").removeClass("hide")
    loadVendorModels($(this).val())

  $(".camera-model").on "change", ->
    $("#snapshot").val $(this).find(":selected").attr("jpg-val")
    $("#snapshot-readonly").val $(this).find(":selected").attr("jpg-val")
    $("#snapshot").addClass("hide")
    $("#snapshot-readonly").removeClass("hide")

onLoadPage = ->
  if $("#last-selected-model").val() isnt ''
    if $("#last-selected-model").val() is "other_default"
      $("#snapshot").removeClass("hide")
      $("#snapshot-readonly").addClass("hide")
    else
      $("#snapshot").addClass("hide")
      $("#snapshot-readonly").removeClass("hide")
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

onAddCamera = ->
  $("#add-button").on 'click', ->
    if $("#camera-name").val().trim() is "" && $("#camera-id").val().trim() is "" && $("#camera-url").val().trim() is "" && $("#snapshot").val().trim() is ""
      Notification.show "Please enter required camera fields: Camera Name, Camera-Id, Camera URL and Snapshot Url."
      return false
    if $("#camera-name").val().trim() is ""
      Notification.show "Please enter required fields: Camera Name."
      return false
    if $("#camera-id").val().trim() is ""
      Notification.show "Please enter required fields: Camera-Id."
      return false
    if $("#camera-url").val().trim() is ""
      Notification.show "Please enter required fields: Camera URL."
      return false
    if $("#snapshot").val().trim() is ""
      Notification.show "Please enter required fields: Snapshot Url."
      return false
    regularExpression = /^(^127\.0\.0\.1)|(^192\.168\.)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)$/
    if regularExpression.test($("#camera-url").val())
      Notification.show "Its your local IP, please provide camera public IP."
      $("#camera-url").css("border-color", "red")
      return false

onCustomizedUrl = ->
  $("#snapshot").on "keyup", ->
    if $("#camera-vendor").val() isnt "other"
      $("#camera-vendor").val("other").trigger("change")
      loadVendorModels($("#camera-vendor").val(), true)

sendTestSnapshotRequest = (loader, index) ->
  vendor_model = vandor_urls[index]
  port = $('#port').val()
  ext_url = $('#camera-url').val()
  if (port != '')
    port = ':' + port
  if vandor_urls.length is 0
    jpg_url = $('#snapshot').val()
  else
    jpg_url = vendor_model.defaults.snapshots.jpg
  # Encode parameters
  jpg_url = jpg_url.replace(/\?/g, 'X_QQ_X').replace(/&/g, 'X_AA_X')
  data = {}
  data.external_url = "http://#{ext_url}#{port}"
  data.jpg_url = jpg_url
  data.cam_username = $("#camera-username").val() unless $("#camera-username").val() is ''
  data.cam_password = $("#camera-password").val() unless $("#camera-password").val() is ''
  data.vendor_id = $("#camera-vendor").val()

  onError = (jqXHR, status, error) ->
    console.log "#{vandor_urls.length - 1} >= #{index}"
    if vandor_urls.length - 1 > index
      sendTestSnapshotRequest(loader, index + 1)
    else
      $('#test-error').text(jqXHR.responseJSON.message)
      loader.stop()

  onSuccess = (result, status, jqXHR) ->
    $('#test-error').text('')
    if result.status is 'ok'
      if (result.data.indexOf('data:text/html') == 0)
        showFeedback("We got a response, but it's not an image")
      else
        showFeedback("We got a snapshot")
        $('#testimg').attr('src', result.data)
        if vandor_urls.length isnt 0
          $("#camera-model").val vendor_model.id
          $("#snapshot").val jpg_url
          $("#snapshot-readonly").val jpg_url
    loader.stop()

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    contentType: "application/x-www-form-urlencoded"
    type: 'POST'
    url: "#{window.Evercam.API_URL}cameras/test"

  sendAJAXRequest(settings)

testSnapshot = ->
  $("#test-snapshot").on 'click', (event) ->
    event.preventDefault()
    if vandor_urls.length is 0 && $('#snapshot').val() is ""
      showFeedback("Please choose camera vendor or add your camera snapshot URL.")
      return
    $('#test-error').text('')
    intRegex = /^\d+$/
    port = $('#port').val()
    ext_url = $('#camera-url').val()

    # Validate port
    if(port != '' && (!intRegex.test(port) || port > 65535))
      showFeedback("Port value is incorrect")
      return

    # Validate host
    if (ext_url is '' || !validate_hostname(ext_url))
      showFeedback("External IP Address (or URL) is incorrect")
      return
    else if (ext_url.indexOf('192.168') == 0 || ext_url.indexOf('127.0.0') == 0 || ext_url.indexOf('10.') == 0)
      showFeedback("This is the Internal IP. Please use the External IP.")
      return
    loader = Ladda.create(this)
    loader.start()
    progress = 0
    interval = setInterval(->
      progress = Math.min(progress + 0.025, 1)
      loader.setProgress(progress)
      if (progress == 1)
        loader.stop()
        clearInterval(interval)
    , 200)
    sendTestSnapshotRequest(loader, 0)

window.initializeAddCameraTest = ->
  Metronic.init()
  Layout.init()
  QuickSidebar.init()
  onLoadPage()
  $.validate()
  handleVendorModelEvents()
  initNotification()
  loadVendors()
  onAddCamera()
  onCustomizedUrl()
  testSnapshot()
