format_time = null

initializeCamerasDataTable = ->
  camera_table = $('#cameras-log-table').DataTable({
    ajax: {
      url: $("#base-url").val(),
      dataSrc: 'cameras',
      error: (xhr, error, thrown) ->
        if xhr.responseJSON
          Notification.show(xhr.responseJSON.message)
        else
          Notification.show("Something went wrong, Please try again.")
    },
    columns: [
      {data: (row, type, set, meta ) ->
        if row.is_online
          return row.name
        else
          return "
          #{row.name} <i class='red main-sidebar fa fa-chain-broken'></i>"
      },
      {data: userCameraRights},
      {data: (row, type, set, meta ) ->
        return "#{row.vendor_name} (#{row.model_name})"
      },
      {data: (row, type, set, meta ) ->
        if row.timezone
          return row.timezone
        else
          return ""
      },
      {data: (row, type, set, meta ) ->
        if row.is_public
          return "<span style='color: green'>Yes</span>"
        else
          return "<span style='color: red'>No</span>"
      },
      {data: (row, type, set, meta ) ->
        if row.cloud_recordings
          if row.cloud_recordings.storage_duration is 1
            return "<span style = '
              font-weight: bold'>#{row.cloud_recordings.status}</span>,
              (24 hours recording)"
          else if row.cloud_recordings.storage_duration is 7
            return "<span style = '
              font-weight: bold'>#{row.cloud_recordings.status}</span>,
              (7 days recording)"
          else if row.cloud_recordings.storage_duration is 30
            return "<span style = '
              font-weight: bold'>#{row.cloud_recordings.status}</span>,
              (30 days recording)"
          else if row.cloud_recordings.storage_duration is 90
            return "<span style = '
              font-weight: bold'>#{row.cloud_recordings.status}</span>,
              (90 days recording)"
          else if row.cloud_recordings.storage_duration is -1
            return "<span style = '
              font-weight: bold'>#{row.cloud_recordings.status}</span>,
              (infinity recording)"
        else
          return ""
      },
    ],
    order: [[ 3, "desc" ]],
    bPaginate: false,
    bSort: true,
    bFilter: false,
    autoWidth: false,
  })

userCameraRights = (row) ->
  str = row.rights
  arr = str.split(",")
  if row.owned == true
    return "Owner"
  else if arr.indexOf("edit") != -1
    return "Full"
  else
    return "Read only"

window.initializeCamerasTable = ->
  format_time = new DateFormatter()
  initializeCamerasDataTable()
