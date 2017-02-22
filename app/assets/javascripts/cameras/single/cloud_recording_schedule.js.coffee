pause_date = null
display_message = false
pause_days = 0
old_frequency = null
old_storage_duration = null
old_status = null
old_schedule = null

window.initScheduleCalendar = ->
  window.scheduleCalendar = $('#cloud-recording-calendar').fullCalendar
    header:
      left: 'prev,next,today'
      center: 'title'
      right: 'month,agendaWeek,agendaDay'
    axisFormat: 'HH'
    defaultView: 'agendaWeek'
    allDaySlot: false
    slotDuration: '00:60:00'
    columnFormat: 'ddd'
    defaultDate: '1970-01-01'
    dayNamesShort: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    editable: true
    eventClick: (event, element) ->
      event.preventDefault
      if (window.confirm("Are you sure you want to delete this event?"))
        scheduleCalendar.fullCalendar('removeEvents', event._id)
        updateScheduleFromCalendar()
    eventDrop: (event) ->
      updateScheduleFromCalendar()
    eventResize: (event) ->
      updateScheduleFromCalendar()
    eventLimit: true
    eventOverlap: false
    eventAfterRender: (event, $el, view ) ->
      start = moment(event.start).format('HH:mm')
      end = moment(event.end).format('HH:mm')
      title = event.title
      # If FullCalendar has removed the title div,
      # then add the title to the time div like FullCalendar would do
      if title
        $el.find(".fc-bg").text(start + "-" + end + " " + title )
      else
        $el.find(".fc-bg").text(start + "-" + end)
    eventColor: '#458CC7'
    firstDay: 1
    height: 'auto'
    select: (start, end) ->
      title = prompt('Event Title:')
      # TODO: select whole day range when allDaySlot is selected
      scheduleCalendar.fullCalendar('renderEvent',
          title: title
          start: start
          end: end - 1
      , true)
      scheduleCalendar.fullCalendar('unselect')
      updateScheduleFromCalendar()
    selectHelper: true
    selectable: true
    timezone: 'local'

isAllDay = (start, end) ->
  !start.hasTime() and !end.hasTime()

updateScheduleToOn = ->
  Evercam.Camera.cloud_recording.schedule = fullWeekSchedule
  Evercam.Camera.cloud_recording.frequency =
    $("#cloud-recording-frequency").val()
  Evercam.Camera.cloud_recording.storage_duration =
    $("#cloud-recording-duration").val()

updateScheduleToOff = ->
  Evercam.Camera.cloud_recording.schedule = fullWeekSchedule
  status = "off"

updateScheduleFromCalendar = ->
  Evercam.Camera.cloud_recording.schedule = parseCalendar()
  Evercam.Camera.cloud_recording.frequency =
    $("#cloud-recording-frequency").val()
  Evercam.Camera.cloud_recording.storage_duration =
    $("#cloud-recording-duration").val()

updateSchedule = ->
  NProgress.start()
  data =
    api_id: Evercam.User.api_id
    api_key: Evercam.User.api_key
    frequency: Evercam.Camera.cloud_recording.frequency
    storage_duration: Evercam.Camera.cloud_recording.storage_duration
    status: Evercam.Camera.cloud_recording.status
    schedule: JSON.stringify(Evercam.Camera.cloud_recording.schedule)

  onError = (data) ->
    switch data.status
      when 403
        showFeedback("You aren't authorized to change the scheduling for camera '#{Evercam.Camera.id}'.")
      else
        showFeedback("Updating recording settings has failed. Please contact support.")
    NProgress.done()

  onSuccess = (data) ->
    duration = JSON.parse(data).cloud_recordings[0].storage_duration
    frequency = JSON.parse(data).cloud_recordings[0].frequency
    status = JSON.parse(data).cloud_recordings[0].status
    Evercam.Camera.cloud_recording.storage_duration = duration
    Evercam.Camera.cloud_recording.frequency = frequency
    Evercam.Camera.cloud_recording.status = status
    $('#cloud-recording-duration').val(duration)
    renderCloudRecordingDuration()
    renderCloudRecordingFrequency()
    $('#cloud-recording-duration').prop("disabled", false)
    showFeedback("Cloud recording schedule was successfully updated.")
    saveOldCRValues()
    NProgress.done()

  settings =
    error: onError
    success: onSuccess
    data: data
    dataType: 'text'
    contentType: "application/x-www-form-urlencoded"
    type: "POST"
    url: "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/apps/cloud-recording"

  $.ajax(settings)

parseCalendar = ->
  events = $('#cloud-recording-calendar').fullCalendar('clientEvents')
  schedule =
    'Monday': []
    'Tuesday': []
    'Wednesday': []
    'Thursday': []
    'Friday': []
    'Saturday': []
    'Sunday': []
  _.forEach events, (event) ->
    startTime = "#{moment(event.start).get('hours')}:#{moment(event.start).get('minutes')}"
    endTime = "#{moment(event.end).get('hours')}:#{moment(event.end).get('minutes')}"
    day = moment(event.start).format('dddd')
    schedule[day] = schedule[day].concat("#{startTime}-#{endTime}")
  schedule

renderEvents = ->
  schedule = Evercam.Camera.cloud_recording.schedule
  days = _.keys(schedule)
  calendarWeek = currentCalendarWeek()

  _.forEach days, (weekDay) ->
    day = schedule[weekDay]
    unless day.length == 0
      _.forEach day, (event) ->
        start = event.split("-")[0]
        end = event.split("-")[1]
        event =
          start: moment("#{calendarWeek[weekDay]} #{start}", "YYYY-MM-DD HH:mm")
          end: moment("#{calendarWeek[weekDay]} #{end}", "YYYY-MM-DD HH:mm")
        scheduleCalendar.fullCalendar('renderEvent', event, true)

currentCalendarWeek = ->
  calendarWeek = {}
  weekStart = scheduleCalendar.fullCalendar('getView').start
  weekEnd = scheduleCalendar.fullCalendar('getView').end
  day = weekStart
  while day.isBefore(weekEnd)
    weekDay = day.format("dddd")
    calendarWeek[weekDay] = day.format('YYYY-MM-DD')
    day.add 1, 'days'
  calendarWeek

editScheduleCalendar = ->
  $('#cloud-recording-calendar-wrap').removeClass('hide' , 'fade')
  $('#cloud-recording-calendar-wrap').addClass('fade in')
  $('.setting-schedule').show()
  $(document).click (event) ->
    if $(event.target).closest('.modal-content').get(0) == null
      $('.setting-schedule').hide()
    return

showEditButton = ->
  $('#show-schedule-calendar').off('click').on 'click' , ->
    if Evercam.Camera.cloud_recording.status is "on-scheduled"
      setTimeout showScheduleCalendar, 5
    editScheduleCalendar()

hideEditButton = ->
  $('#schdule-label').removeClass('hide')

hideScheduleLabel = ->
  $('#schdule-label').addClass('hide')

showScheduleLabel = ->
  $('#schdule-label').removeClass('hide')

showScheduleCalendar = ->
  $("#uniform-cloud-recording-on-scheduled div").addClass 'checked'
  $(".setting-schedule .modal-dialog").animate { "margin-top": "7%" }
  $('#calendarfull-wrap').show('slow')
  scheduleCalendar.fullCalendar('render')
  if scheduleCalendar.is(':visible')
    renderEvents()

hideScheduleCalendar = ->
  $('#calendarfull-wrap').hide('slow')
  $("#uniform-cloud-recording-on-scheduled div").removeClass 'checked'

showFrequencySelect = ->
  $('#cloud-recording-frequency-wrap').show('slow')

hideFrequencySelect = ->
  $('#cloud-recording-frequency-wrap').hide('slow')

showDurationSelect = ->
  $('#cloud-recording-duration-wrap').show('slow')
  if Evercam.Camera.cloud_recording.storage_duration is -1
    $('#cloud-recording-duration').attr('disabled',true)

hideDurationSelect = ->
  $('#cloud-recording-duration-wrap').hide('slow')

updateFrequencyTo60 = ->
  $("#cloud-recording-frequency").val(60)

window.fullWeekSchedule =
  "Monday": ["00:00-23:59"]
  "Tuesday": ["00:00-23:59"]
  "Wednesday": ["00:00-23:59"]
  "Thursday": ["00:00-23:59"]
  "Friday": ["00:00-23:59"]
  "Saturday": ["00:00-23:59"]
  "Sunday": ["00:00-23:59"]

perfomAction = ->
  status = $('input[name=cloud_recording]:checked').val()
  switch status
    when "on","paused"
      updateScheduleToOn()
    when "on-scheduled"
      updateScheduleFromCalendar()

handleFrequencySelect = ->
  $("#cloud-recording-frequency").off("change").on "change" , (event) ->
    perfomAction()

handleDurationSelect = ->
  $("#cloud-recording-duration").off("change").on "change" , (event) ->
    perfomAction()

handleStatusSelect = ->
  $("#recording-toggle input").off("ifChecked").on "ifChecked", (event) ->
    status = Evercam.Camera.cloud_recording.status
    storage = Evercam.Camera.cloud_recording.storage_duration
    Evercam.Camera.cloud_recording.status = $(this).val()
    switch $(this).val()
      when "on"
        if display_message
          $("#cr_change_to").val("on")
          $("#off-pause-modal").modal('show')
        else
          hideScheduleCalendar()
          showFrequencySelect()
          showDurationSelect()
          updateFrequencyTo60()
          updateScheduleToOn()
      when "on-scheduled"
        if display_message
          $("#cr_change_to").val("on-scheduled")
          $("#off-pause-modal").modal('show')
        else
          showScheduleCalendar()
          showFrequencySelect()
          showDurationSelect()
          updateFrequencyTo60()
          updateScheduleToOn()
      when "off"
        hideFrequencySelect()
        hideDurationSelect()
        hideScheduleCalendar()
        updateScheduleToOff()

getLastPaused = (duration) ->
  data =
    api_id: Evercam.User.api_id
    api_key: Evercam.User.api_key
    objects: true
    limit: 5
    page: 0
    types: "cloud recordings updated"

  onError = (data) ->
    false

  onSuccess = (data) ->
    $.each data.logs, (index, log) ->
      if log.extra.status is "paused"
        pause_date = new Date(log.done_at*1000)
        renderPauseMessage(pause_date)
        return false

  settings =
    error: onError
    success: onSuccess
    data: data
    dataType: 'json'
    type: "GET"
    url: "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/logs"

  $.ajax(settings)

renderCloudRecordingDuration = ->
  $("#cloud-recording-duration").val(Evercam.Camera.cloud_recording.storage_duration)
  recording_duration_value = $("#cloud-recording-duration :selected").text()
  if Evercam.Camera.cloud_recording.status is "off"
    $(".recording-text .storage").hide('slow')
    $(".recording-text .off-status").text('Off')
  else if Evercam.Camera.cloud_recording.status is "on"
    $(".recording-text .off-status").text('Continuous')
    $(".recording-text .storage").show('slow')
    $(".storage-duration").text(recording_duration_value)
  else if Evercam.Camera.cloud_recording.status is "paused"
    $(".recording-text .off-status").text('Paused')
    $(".storage-duration").text(recording_duration_value)
  else
    $(".recording-text .off-status").text('On Schedule')
    $(".recording-text .storage").show('slow')
    $(".storage-duration").text(recording_duration_value)

renderCloudRecordingFrequency = ->
  $("#cloud-recording-frequency").val(Evercam.Camera.cloud_recording.frequency)
  recording_frequency_value = $("#cloud-recording-frequency :selected").text()
  if Evercam.Camera.cloud_recording.status is "off"
    $(".recording-text .frequency-text").hide('slow')
    $(".recording-text .off-status").text('Off')
  else if Evercam.Camera.cloud_recording.status is "on"
    $(".recording-text .off-status").text('Continuous')
    $(".recording-text .frequency-text").show('slow')
    $(".recording-frequency").text(recording_frequency_value)
  else if Evercam.Camera.cloud_recording.status is "paused"
    $(".recording-text .off-status").text('Paused')
    $(".recording-frequency").text(recording_frequency_value)
  else
    $(".recording-text .off-status").text('On Schedule')
    $(".recording-text .frequency-text").show('slow')
    $(".recording-frequency").text(recording_frequency_value)

renderCloudRecordingStatus = ->
  switch Evercam.Camera.cloud_recording.status
    when "on"
      $("#cloud-recording-on").iCheck('check')
      showFrequencySelect()
      showDurationSelect()
      hideScheduleCalendar()
      renderCloudRecordingDuration()
      renderCloudRecordingFrequency()
    when "on-scheduled"
      $("#cloud-recording-on-scheduled").iCheck('check')
      showScheduleCalendar()
      showFrequencySelect()
      showDurationSelect()
      renderCloudRecordingDuration()
      renderCloudRecordingFrequency()
    when "off"
      $("#cloud-recording-off").iCheck('check')
      hideScheduleCalendar()
      hideFrequencySelect()
      hideDurationSelect()
    when "paused"
      $("#cloud-recording-paused").iCheck('check')

saveScheduleSettings = ->
  $(".schedule-save").off('click').on 'click', ->
    new_cr_values = Evercam.Camera.cloud_recording
    new_frequency = parseInt(new_cr_values.frequency)
    new_storage = parseInt(new_cr_values.storage_duration)
    new_status = new_cr_values.status
    new_schedule = new_cr_values.schedule

    if new_frequency isnt old_frequency or
       new_storage isnt old_storage_duration or
       new_status isnt old_status or
       is_equal_schedule(new_schedule, old_schedule) isnt true
      updateSchedule()
    $('#cloud-recording-calendar-wrap').modal('hide')

renderPauseMessage = (from_date) ->
  storage = Evercam.Camera.cloud_recording.storage_duration
  to_date = new Date()
  pause_days = parseInt((to_date - from_date)/86400000)
  if pause_days >= 1
    display_message = true
  else
    display_message = false
  storage_text = "#{storage} days"
  if storage is 1
    storage_text = "24 hours"
  $(".lblResumePeriod").text(storage_text)
  $(".lblPauseFrom").text("#{pause_days} days")

resumeCR = ->
  $("#resume-recordings").on "click", ->
    switch $("#cr_change_to").val()
      when "on"
        hideScheduleCalendar()
        showFrequencySelect()
        showDurationSelect()
        updateScheduleToOn()
      when "on-scheduled"
        showScheduleCalendar()
        showFrequencySelect()
        showDurationSelect()
        updateScheduleToOn()
    $("#cr_change_to").val("")
    $("#off-pause-modal").modal('hide')

  $("#resume-recordings-no").on "click", ->
    $("#cr_change_to").val("")
    $("#cloud-recording-paused").iCheck('check')

  $("#off-pause-modal").on "hide.bs.modal", ->
    if $("#cr_change_to").val() isnt ""
      $("#cr_change_to").val("")
      $("#cloud-recording-paused").iCheck('check')

is_equal_schedule = (schedule, original) ->
  if "#{schedule["Monday"]}".trim() is "#{original["Monday"]}".trim() and
     "#{schedule["Tuesday"]}".trim() is "#{original["Tuesday"]}".trim() and
     "#{schedule["Wednesday"]}".trim() is "#{original["Wednesday"]}".trim() and
     "#{schedule["Thursday"]}".trim() is "#{original["Thursday"]}".trim() and
     "#{schedule["Friday"]}".trim() is "#{original["Friday"]}".trim() and
     "#{schedule["Saturday"]}".trim() is "#{original["Saturday"]}".trim() and
     "#{schedule["Sunday"]}".trim() is "#{original["Sunday"]}".trim()
    return true
  else
    return false

saveOldCRValues = ->
  old_frequency = Evercam.Camera.cloud_recording.frequency
  old_storage_duration = Evercam.Camera.cloud_recording.storage_duration
  old_status = Evercam.Camera.cloud_recording.status
  old_schedule = Evercam.Camera.cloud_recording.schedule

window.initCloudRecordingSettings = ->
  saveOldCRValues()
  if Evercam.Camera.cloud_recording.status is "paused"
    getLastPaused(Evercam.Camera.cloud_recording.storage_duration)
  renderCloudRecordingDuration()
  renderCloudRecordingStatus()
  renderCloudRecordingFrequency()
  handleDurationSelect()
  handleFrequencySelect()
  showEditButton()
  handleStatusSelect()
  saveScheduleSettings()
  resumeCR()
