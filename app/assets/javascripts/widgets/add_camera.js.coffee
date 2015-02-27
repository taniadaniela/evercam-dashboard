#= require jquery
#= require jquery_ujs
#= require bootstrap

Evercam_API_URL = 'https://api.evercam.io/v1/'

sortByKey = (array, key) ->
  array.sort (a, b) ->
    x = a[key]
    y = b[key]
    (if (x < y) then -1 else ((if (x > y) then 1 else 0)))

loadVendors = ->
  data = {}

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
    url: "#{Evercam_API_URL}vendors"

  jQuery.ajax(settings)
  true

loadVendorModels = (vendor_id) ->
  $("#camera-model option").remove()
  $("#camera-model").append('<option value="">Loading...</option>');
  if vendor_id is ""
    return

  data = {}
  data.vendor_id = vendor_id
  data.limit = 400

  onError = (jqXHR, status, error) ->
    false

  onSuccess = (result, status, jqXHR) ->
    $("#camera-model option").remove()
    if result.models.length == 0
      $("#camera-model").append('<option value="">No Model Found</option>');
      return

    models = sortByKey(result.models, "name")
    for model in models
      #selected = if model.id is $("#last-selected-model").val() then 'selected="selected"' else ''
      jpg_url = if model.defaults.snapshots then model.defaults.snapshots.jpg else ''
      if jpg_url is "unknown"
        jpg_url = ""
      $("#camera-model").append("<option jpg-val='#{jpg_url}' value='#{model.id}'>#{model.name}</option>")

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    contentType: "application/json; charset=utf-8"
    type: 'GET'
    url: "#{Evercam_API_URL}models.json"

  jQuery.ajax(settings)
  true

handleVendorModelEvents = ->
  $("#camera-vendor").on "change", ->
    loadVendorModels($(this).val())

  $("#camera-model").on "change", ->
    $("#camera-snapshot-url").val $(this).find(":selected").attr("jpg-val")

useAuthentication = ->
  $("#required-authentication").on 'click', ->
    if $(this).is(":checked")
      $("#authentication").removeClass("hide")
    else
      $("#authentication").addClass("hide")

handleInputEvents = ->
  $("#camera-url").on 'keyup', (e) ->
    console.log validate_hostname($(this).val())
  $("#camera-port").on 'keyup', (e) ->
    console.log validate_hostname($(this).val())
  $("#camera-snapshot-url").on 'keyup', (e) ->
    console.log validate_hostname($(this).val())

validate_hostname = (str) ->
  ValidIpAddressRegex = /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/
  ValidHostnameRegex = /^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$/
  ValidIpAddressRegex.test(str) or ValidHostnameRegex.test(str)

$ ->
  useAuthentication()
  loadVendors()
  handleVendorModelEvents()
  handleInputEvents()