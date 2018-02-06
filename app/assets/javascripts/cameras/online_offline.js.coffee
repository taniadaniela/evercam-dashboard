evercam_logs = undefined

startReport = (logs) ->
  evercam_logs = logs
  chart = visavailChart()
  chart.width $('#visavail_container').width() - 200
  $('#draw_report').text ''
  d3.select('#draw_report').datum(logs).call chart
  return

onResize = ->
  $(window).resize ->
    startReport(evercam_logs)
    centerLoadingAnimation()

selectHistoryDays = ->
  $('#select-history-days, #type-all').on 'change', ->
    onChangeStatusReportDays($("#select-history-days").val(), $("input[name='offline_only']:checked").val())
    $('#visavail_container').addClass 'opacity'
    $('#status-report .loading-image-div').removeClass 'hide'
    $('#select-history-days ').attr 'disabled', 'disabled'

toggleLoadingImage = ->
  $('#visavail_container').removeClass 'opacity'
  $('#status-report .loading-image-div').addClass 'hide'
  $('#status-dropdown').removeClass 'hide'
  $('#select-history-days ').removeAttr 'disabled'

onChangeStatusReportDays = (days, offline_only) ->
  data = {}
  data.history_days = days
  data.offline_only = offline_only

  onError = (jqXHR, status, error) ->
    showError(jqXHR.responseJSON.message)
    toggleLoadingImage()

  onSuccess = (response, success, jqXHR) ->
    startReport(response)
    toggleLoadingImage()

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    type: 'GET'
    url: "/status_report"

  sendAJAXRequest(settings)
  true

centerLoadingAnimation = ->
  offset = ($(window).height() - 100) / 2
  $("#loading-image-div").css "margin-top", offset

window.initializeOnlineOfflineReport = ->
  onResize()
  selectHistoryDays()
  onChangeStatusReportDays()
  centerLoadingAnimation()
