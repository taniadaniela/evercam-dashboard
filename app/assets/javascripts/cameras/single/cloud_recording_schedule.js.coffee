window.initScheduleCalendar = ->
  window.scheduleCalendar = $('#cloud-recording-calendar').fullCalendar
    axisFormat: 'HH'
    allDaySlot: false
    columnFormat: 'ddd'
    defaultDate: '1970-01-01'
    defaultView: 'agendaWeek'
    dayNamesShort: ["S", "M", "T", "W", "T", "F", "S"]
    eventColor: '#428bca'
    editable: true
    eventClick: (event, element) ->
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
      left: ''
      center: ''
      right: ''
    height: 'auto'
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

  frequency = 60
  storage_duration = -1
  schedule = JSON.stringify(fullWeekSchedule)
  updateSchedule(frequency, storage_duration, schedule, "POST")

updateScheduleToOff = ->
  Evercam.Camera.cloud_recording.schedule = fullWeekSchedule

  frequency = 1
  storage_duration = -1
  schedule = JSON.stringify(fullWeekSchedule)
  updateSchedule(frequency, storage_duration, schedule, "DELETE")

updateScheduleFromCalendar = ->
  frequency = 60
  storage_duration = -1
  schedule = JSON.stringify(parseCalendar())
  updateSchedule(frequency, storage_duration, schedule, "POST")

updateSchedule = (frequency, storage_duration, schedule, type) ->
  data =
    api_id: Evercam.User.api_id
    api_key: Evercam.User.api_key
    frequency: frequency
    storage_duration: storage_duration
    schedule: schedule

  onError = ->
    showFeedback("Updating recording settings has failed. Please contact support.")

  onSuccess = (data) ->
    showFeedback("Cloud recording schedule was successfully updated.")

  settings =
    error: onError
    success: onSuccess
    cache: false
    data: data
    dataType: 'text'
    type: type
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

showShowScheduleLink = ->
  $("#show-schedule").removeClass('hide')

showHideScheduleLink = ->
  $("#hide-schedule").removeClass('hide')

hideShowScheduleLink = ->
  $("#show-schedule").addClass('hide')

hideHideScheduleLink = ->
  $("#hide-schedule").addClass('hide')

showScheduleCalendar = ->
  $('#cloud-recording-calendar').removeClass('hide')
  scheduleCalendar.fullCalendar('render')
  renderEvents()

hideScheduleCalendar = ->
  $('#cloud-recording-calendar').addClass('hide')

window.fullWeekSchedule =
  "Monday": ["00:00-23:59"]
  "Tuesday": ["00:00-23:59"]
  "Wednesday": ["00:00-23:59"]
  "Thursday": ["00:00-23:59"]
  "Friday": ["00:00-23:59"]
  "Saturday": ["00:00-23:59"]
  "Sunday": ["00:00-23:59"]

window.handleRecordingToggle = ->
  $("#recording-toggle input").on "ifChecked", (event) ->
    switch $(this).val()
      when "on"
        hideShowScheduleLink()
        hideHideScheduleLink()
        hideScheduleCalendar()
        updateScheduleToOn()
      when "on-scheduled"
        showShowScheduleLink()
        hideHideScheduleLink()
      when "off"
        hideShowScheduleLink()
        hideHideScheduleLink()
        hideScheduleCalendar()
        updateScheduleToOff()

window.setCloudRecordingToggle = ->
  if Evercam.Camera.cloud_recording.frequency == 1
    $("#cloud-recording-off").iCheck('check')
  else
    if JSON.stringify(Evercam.Camera.cloud_recording.schedule) == JSON.stringify(fullWeekSchedule)
      $("#cloud-recording-on").iCheck('check')
    else
      $("#cloud-recording-on-scheduled").iCheck('check')
      showShowScheduleLink()
  handleRecordingToggle()

window.handleShowScheduleClick = ->
  $("#show-schedule").on "click", ->
    showHideScheduleLink()
    hideShowScheduleLink()
    showScheduleCalendar()

window.handleHideScheduleClick = ->
  $("#hide-schedule").on "click", ->
    showShowScheduleLink()
    hideHideScheduleLink()
    hideScheduleCalendar()
