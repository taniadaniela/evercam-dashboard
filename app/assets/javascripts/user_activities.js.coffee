parser = undefined
format_time = null
table = undefined

initializeDataTable = ->
  table = $('#user-activity').DataTable({
    ajax: {
      url: "#{Evercam.API_URL}users/session/activities?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}&limit=10000#{get_search_query()}",
      dataSrc: (d) ->
        d.user_logs
      error: (xhr, error, thrown) ->
        if xhr.responseJSON
          Notification.show(xhr.responseJSON.message)
        else
          Notification.show("Something went wrong, Please try again.")
        NProgress.done()
    },
    columns: [
      {data: (row, type, set, meta) ->
        if row.extra && row.extra.agent
          if row.extra.agent.indexOf("iPhone") isnt -1
            return "<i class='fab fa-apple'></i> iOS APP"
          else if row.extra.agent.indexOf("java") isnt -1
            return "<i class='fab fa-android'></i> Andriod APP"
          else
            agent = parse_agent_string(row.extra.agent)
            if agent.browser.name
              return "<i class='fab fa-#{agent.browser.name.toLowerCase()}'></i> #{agent.browser.name} on #{agent.os.name}"
            else
              ""
        else
          ""
      , orderable: false},
      {data: (row, type, set, meta) ->
        if row.extra && row.extra.ip
          return row.extra.ip
        else
          ""
      , orderable: false},
      {data: (row, type, set, meta) ->
        if row.extra && row.extra.country && row.extra.country_code
          return "<img src='https://www.countryflags.io/#{row.extra.country_code}/shiny/16.png'> #{row.extra.country}"
        else
          ""
      , orderable: false},
      {data: ( row, type, set, meta ) ->
        time = moment.tz(row.done_at*1000, "UTC")
        return "
          <div class='#{row.done_at} thumb-div'>
          </div>\
          <span>#{moment(time).format('MMMM Do YYYY, H:mm:ss')}</span>"
      , sType: 'uk_datetime', orderable: false },
      {data: ( row, type, set, meta ) ->
        if row.action is 'shared' or row.action is 'stopped sharing' or row.action is "updated share"
          desc = ""
          if row.action is "updated share"
            desc = "rights "
          if row.extra && row.extra.with
            return ("#{row.action} #{desc}with #{row.extra.with}")
          else
            return row.action
        else
            return row.action
      , orderable: false}
    ],
    autoWidth: false,
    info: false,
    bPaginate: false,
    pageLength: 100
    "language": {
      "emptyTable": "No data available"
    },
    order: [],
    drawCallback: ->
      NProgress.done()
    initComplete: (settings, json) ->
      $("#user-activity_length").hide()
      $("#user-activity_filter").hide()
      $("#user-activity_wrapper div.col-sm-12").removeClass("col-sm-12")
  })
  $("#user-activity_filter").hide()
  $("#user-activity_wrapper div.col-sm-12").removeClass("col-sm-12")

parse_agent_string = (agent_string) ->
  parser.setUA(agent_string)
  result = parser.getResult()
  data =
    browser: result.browser
    device: result.device
    os: result.os
    os_version: result.os.version
    engine_name: result.engine.name
    cpu_architecture: result.cpu.architecture

initDatepicker = ->
  $(".datetimepicker").datetimepicker
    timepicker: false
    closeOnDateSelect: 0
    format: 'd/m/Y'

getDate = (type) ->
  DateFromTime = new Date(moment.utc().format('MM/DD/YYYY, HH:mm:ss'))
  if type is "from"
    DateFromTime.setMonth(DateFromTime.getMonth() - 5)
    DateFromTime.setHours(0)
    DateFromTime.setMinutes(0)
  if type is "to"
    DateFromTime.setHours(23)
    DateFromTime.setMinutes(59)
  Dateformated =  format_time.formatDate(DateFromTime, 'd/m/Y')
  return Dateformated

get_search_query = ->
  from_date = moment($('#datetimepicker_from').val(), "DD-MM-YYYY H:mm")
  to_date = moment($('#datetimepicker_to').val(), "DD-MM-YYYY H:mm")
  from = from_date._d.getTime()/ 1000
  to = to_date._d.getTime()/ 1000

  fromto_seg = ''
  fromto_seg += '&from=' + from unless isNaN(from)
  fromto_seg += '&to=' + to unless isNaN(to)
  return fromto_seg

searchLogs = ->
  $("#search-logs").on "click", ->
    url = "#{Evercam.API_URL}users/session/activities?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}&limit=10000#{get_search_query()}"
    table.ajax.url(url).load() if table?

window.initializeUserActivity = ->
  format_time = new DateFormatter()
  $("#datetimepicker_from").val(getDate("from"))
  $("#datetimepicker_to").val(getDate("to"))
  initDatepicker()
  initializeDataTable()
  parser = new UAParser()
  searchLogs()
