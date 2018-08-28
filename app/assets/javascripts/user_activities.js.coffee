parser = undefined

initializeDataTable = ->
  table = $('#user-activity').DataTable({
    ajax: {
      url: "#{Evercam.API_URL}users/session/activities?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}&limit=10000",
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

window.initializeUserActivity = ->
  initializeDataTable()
  parser = new UAParser()
