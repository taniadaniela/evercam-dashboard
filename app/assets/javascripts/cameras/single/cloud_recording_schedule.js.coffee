window.initScheduleCalendar = ->
  window.scheduleCalendar = $('#cloud-recording-calendar').fullCalendar
    axisFormat: 'HH'
    allDaySlot: false
    slotDuration: '00:90:00'
    columnFormat: 'ddd'
    defaultDate: '1970-01-01'
    dayNamesShort: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    eventColor: '#428bca'
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
    firstDay: 1
    header:
      left: 'prev,next today',
      center: 'title'
      right: 'month,agendaWeek,agendaDay'
    height: 'auto'
    events: '/application/events'
    select: (start, end) ->
      # TODO: select whole day range when allDaySlot is selected
      eventData =
        start: start
        end: end
      scheduleCalendar.fullCalendar('renderEvent', eventData, true)
      scheduleCalendar.fullCalendar('unselect')
      updateScheduleFromCalendar()
    selectHelper: true
    selectable: true
    timezone: 'local'

isAllDay = (start, end) ->
  !start.hasTime() and !end.hasTime()

updateScheduleToOn = ->
  Evercam.Camera.cloud_recording.schedule = fullWeekSchedule
  frequency = $("#cloud-recording-frequency").val()
  storage_duration = $("#cloud-recording-duration").val()
  status = Evercam.Camera.cloud_recording.status
  schedule = JSON.stringify(fullWeekSchedule)
  updateSchedule(frequency, storage_duration, schedule, status)

updateScheduleToOff = ->
  Evercam.Camera.cloud_recording.schedule = fullWeekSchedule

  frequency = 1
  storage_duration = 1
  status = "off"
  schedule = JSON.stringify(fullWeekSchedule)
  updateSchedule(frequency, storage_duration, schedule, status)

updateScheduleFromCalendar = ->
  Evercam.Camera.cloud_recording.schedule = parseCalendar()
  frequency = $("#cloud-recording-frequency").val()
  storage_duration = $("#cloud-recording-duration").val()
  status = Evercam.Camera.cloud_recording.status
  schedule = JSON.stringify(parseCalendar())
  updateSchedule(frequency, storage_duration, schedule, status)

updateSchedule = (frequency, storage_duration, schedule, status) ->
  if status is 'off'
    storage_duration = 1
  if status is 'on' and storage_duration is -1
    storage_duration = 1
  if status is 'on-scheduled' and storage_duration is -1
    storage_duration = 1
  if status is 'on' and storage_duration is null
    storage_duration = 1
  if status is 'on-scheduled' and storage_duration is null
    storage_duration = 1
  data =
    api_id: Evercam.User.api_id
    api_key: Evercam.User.api_key
    frequency: frequency
    storage_duration: storage_duration
    status: status
    schedule: schedule

  onError = (data) ->
    switch data.status
      when 403
        showFeedback("You aren't authorized to change the scheduling for camera '#{Evercam.Camera.id}'.")
      else
        showFeedback("Updating recording settings has failed. Please contact support.")

  onSuccess = (data) ->
    Evercam.Camera.cloud_recording.storage_duration = JSON.parse(data).cloud_recordings[0].storage_duration
    Evercam.Camera.cloud_recording.frequency = JSON.parse(data).cloud_recordings[0].frequency
    $('#cloud-recording-duration').val(Evercam.Camera.cloud_recording.storage_duration)
    $('#cloud-recording-duration').attr('disabled',false)
    showFeedback("Cloud recording schedule was successfully updated.")

  settings =
    error: onError
    success: onSuccess
    cache: false
    data: data
    dataType: 'text'
    type: "POST"
    url: "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/apps/cloud-recording"

  sendAJAXRequest(settings)

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
  $('#show-schedule-calendar').click ->
    editScheduleCalendar()
    return

hideEditButton = ->
  $('#schdule-label').removeClass('hide')

hideScheduleLabel = ->
  $('#schdule-label').addClass('hide')

showScheduleLabel = ->
  $('#schdule-label').removeClass('hide')

showScheduleCalendar = ->
  $('#cloud-recording-calendar').removeClass('hide')
  scheduleCalendar.fullCalendar('render')
  if scheduleCalendar.is(':visible')
    renderEvents()

hideScheduleCalendar = ->
  $('#cloud-recording-calendar').addClass('hide')

showFrequencySelect = ->
  $('#cloud-recording-frequency-wrap').removeClass('hide')

hideFrequencySelect = ->
  $('#cloud-recording-frequency-wrap').addClass('hide')

showDurationSelect = ->
  $('#cloud-recording-duration-wrap').removeClass('hide')
  if Evercam.Camera.cloud_recording.storage_duration is -1
    $('#cloud-recording-duration').attr('disabled',true)

hideDurationSelect = ->
  $('#cloud-recording-duration-wrap').addClass('hide')

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

handleFrequencySelect = ->
  $("#cloud-recording-frequency").off("change").on "change" , (event) ->
    if JSON.stringify(Evercam.Camera.cloud_recording.schedule) == JSON.stringify(fullWeekSchedule)
      updateScheduleToOn()
    else
      updateScheduleFromCalendar()

handleDurationSelect = ->
  $("#cloud-recording-duration").off("change").on "change" , (event) ->
    if JSON.stringify(Evercam.Camera.cloud_recording.schedule) == JSON.stringify(fullWeekSchedule)
      updateScheduleToOn()
    else
      updateScheduleFromCalendar()

handleStatusSelect = ->
  $("#recording-toggle input").off("ifChecked").on "ifChecked", (event) ->
    Evercam.Camera.cloud_recording.status = $(this).val()
    switch $(this).val()
      when "on"
        hideScheduleCalendar()
        showFrequencySelect()
        showDurationSelect()
        updateFrequencyTo60()
        updateScheduleToOn()
      when "on-scheduled"
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

renderCloudRecordingDuration = ->
  $("#cloud-recording-duration").val(Evercam.Camera.cloud_recording.storage_duration)

renderCloudRecordingFrequency = ->
  $("#cloud-recording-frequency").val(Evercam.Camera.cloud_recording.frequency)

renderCloudRecordingStatus = ->
  switch Evercam.Camera.cloud_recording.status
    when "on"
      $("#cloud-recording-on").iCheck('check')
      showFrequencySelect()
      showDurationSelect()
      hideScheduleCalendar()
    when "on-scheduled"
      $("#cloud-recording-on-scheduled").iCheck('check')
      showScheduleCalendar()
      showFrequencySelect()
      showDurationSelect()
    when "off"
      $("#cloud-recording-off").iCheck('check')

window.initCloudRecordingSettings = ->
  renderCloudRecordingDuration()
  renderCloudRecordingFrequency()
  renderCloudRecordingStatus()
  handleDurationSelect()
  handleFrequencySelect()
  showEditButton()
  handleStatusSelect()
