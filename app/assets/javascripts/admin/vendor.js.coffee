vendor_table = null

sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = jQuery.ajax(settings)

initializeDataTable = ->
  headers = undefined
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers = 'X-CSRF-Token': token.attr('content')

  vendor_table = $('#datatable_vendors').DataTable({
    ajax: {
      url: "#{Evercam.API_URL}vendors",
      'headers': headers
      dataSrc: 'vendors',
      error: (xhr, error, thrown) ->
        console.log(xhr.responseJSON.message)
    },
    columns: [
      {data: "id", width: '20%', type: 'string' },
      {data: "name", width: '20%'},
      {data: "known_macs", width: '60%', 'render': showMacs }
    ],
    iDisplayLength: 50
    aLengthMenu: [
      [25, 50, 100, 200, -1]
      [25, 50, 100, 200, "All"]
    ]
    aaSorting: [1, "asc"]
  })

showMacs = (macs, type, row) ->
  known_macs = "#{macs}"
  return "<span style='word-wrap: break-word;'>#{known_macs.replace(RegExp(",", "g"), ", ")}</span>"

clearForm = ->
  $("#vendor-id").val('')
  $("#name").val('')
  $("#known-macs").val('')
  $(".vendor-alert").slideUp()

handleAddNewModel = ->
  $("#save-vendor").on 'click', ->

    if $("#vendor-id").val() is ''
      $(".vendor-alert").html('Vendor id can not be empty.')
      $(".vendor-alert").slideDown()
      return
    if $("#name").val() is ''
      $(".vendor-alert").html('Vendor name can not be empty.')
      $(".vendor-alert").slideDown()
      return
    $(".vendor-alert").slideUp()

    data = {}
    data.id = $("#vendor-id").val()
    data.name = $("#name").val()
    data.macs = $("#known-macs").val() unless $("#known-macs").val() is ''

    onError = (jqXHR, status, error) ->
      $(".vendor-alert").html(jqXHR.responseJSON.message)
      $(".vendor-alert").slideDown()
      false

    onSuccess = (result, status, jqXHR) ->
      vendor_models_table.getDataTable().ajax.reload()
      $('#add-vendor').modal('hide')
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
      url: "#{Evercam.API_URL}vendors?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"

    sendAJAXRequest(settings)

onModelClose = ->
  $(".modal").on "hide.bs.modal", ->
    clearForm()

window.initializeVendors = ->
  initializeDataTable()
  handleAddNewModel()
  onModelClose()
