vendor_models_table = null

sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = jQuery.ajax(settings)
  true

initializeDataTable = ->
  vendor_models_table = new Datatable
  headers = undefined
  token = $('meta[name="csrf-token"]')

  if token.size() > 0
    headers = 'X-CSRF-Token': token.attr('content')

  vendor_models_table.init
    src: $('#datatable_vendor_models')
    onSuccess: (grid) ->
      # execute some code after table records loaded
      return
    onError: (grid) ->
      # execute some code on network or other general error
      return
    onDataLoad: (grid) ->
      $('.dataTables_info').append ', ' + numberWithCommas($('#total_vendors').val()) + ' vendors'
      $('.dataTables_info').append ', ' + numberWithCommas($('#total_cameras').val()) + ' Cameras'
      return
    loadingMessage: 'Loading...'
    dataTable:
      'bStateSave': true
      'lengthMenu': [
        [ 25, 50, 100, 200, -1 ]
        [ 25, 50, 100, 200, 'All' ]
      ]
      'pageLength': 50
      'ajax':
        'method': 'GET'
        'headers': headers
        'url': 'models/load.vendor.model'
      'order': [ [ 0, 'asc' ] ]
      initComplete: ->
        $('#vendor-model-list-row').removeClass 'hide'
        return
  vendor_models_table.getTableWrapper().on 'keyup', '.table-group-action-input', (e) ->
    e.preventDefault()
    action = $('.table-group-action-input', vendor_models_table.getTableWrapper())
    if action.val() != ''
      vendor_models_table.setAjaxParam 'vendor', action.val()
      vendor_models_table.setAjaxParam 'vendor_model', action.val()
      vendor_models_table.getDataTable().ajax.reload()
      vendor_models_table.clearAjaxParams()
    return
  $('#columns-vis').on 'change', (e) ->
    e.preventDefault()
    # Get the column API object
    column = vendor_models_table.column($(this).attr('data-column'))
    # Toggle the visibility
    column.visible !column.visible()

numberWithCommas = (x) ->
  x.toString().replace /\B(?=(\d{3})+(?!\d))/g, ','

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
      selected = if vendor.id is 'other' then 'selected="selected"' else ''
      $("#vendor").append("<option value='#{vendor.id}' #{selected}>#{vendor.name}</option>")

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    contentType: "application/json; charset=utf-8"
    type: 'GET'
    url: "#{Evercam.API_URL}vendors.json"

  sendAJAXRequest(settings)
  true

clearForm = ->
  $("#model-id").val('')
  $("#vendor").val('other')
  $("#name").val('')
  $("#jpg-url").val('')
  $("#mjpg-url").val('')
  $("#mpeg4-url").val('')
  $("#mobile-url").val('')
  $("#h264-url").val('')
  $("#lowres-url").val('')
  $("#default-username").val('')
  $("#default-password").val('')
  $(".model-alert").slideUp()

handleAddNewModel = ->
  $("#save-model").on 'click', ->

    if $("#model-id").val() is ''
      $(".model-alert").html('Model id can not be empty.')
      $(".model-alert").slideDown()
      return
    if $("#vendor").val() is ''
      $(".model-alert").html('Please select vendor.')
      $(".model-alert").slideDown()
      return
    if $("#name").val() is ''
      $(".model-alert").html('Model name can not be empty.')
      $(".model-alert").slideDown()
      return
    $(".model-alert").slideUp()

    data = {}
    data.id = $("#model-id").val()
    data.vendor_id = $("#vendor").val()
    data.name = $("#name").val()
    data.jpg_url = $("#jpg-url").val() unless $("#jpg-url").val() is ''
    data.mjpg_url = $("#mjpg-url").val() unless $("#mjpg-url").val() is ''
    data.mpeg4_url = $("#mpeg4-url").val() unless $("#mpeg4-url").val() is ''
    data.mobile_url = $("#mobile-url").val() unless $("#mobile-url").val() is ''
    data.h264_url = $("#h264-url").val() unless $("#h264-url").val() is ''
    data.lowres_url = $("#lowres-url").val() unless $("#lowres-url").val() is ''
    data.default_username = $("#default-username").val() unless $("#default-username").val() is ''
    data.default_password = $("#default-password").val() unless $("#default-password").val() is ''

    onError = (jqXHR, status, error) ->
      $(".model-alert").html(jqXHR.responseJSON.message)
      $(".model-alert").slideDown()
      false

    onSuccess = (result, status, jqXHR) ->
      vendor_models_table.getDataTable().ajax.reload()
      $("#close-dialog").click()
      clearForm()
      true

    settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      contentType: "application/x-www-form-urlencoded"
      type: 'POST'
      url: "#{Evercam.API_URL}models?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"

    sendAJAXRequest(settings)

onModelClose = ->
  $(".modal").on "hide.bs.modal", ->
    clearForm()

window.initializeVendorModel = ->
  initializeDataTable()
  loadVendors()
  handleAddNewModel()
  onModelClose()