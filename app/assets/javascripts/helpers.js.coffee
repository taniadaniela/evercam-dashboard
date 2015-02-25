window.refreshThumbnails = ->
  $('.snapshot-refresh').each ->
     refreshCameraThumbnail(this)

refreshCameraThumbnail = (element) ->
  live_snapshot_url = $(element).attr('data-proxy') 
  img = new Image()
  img.onload = ->
    $(element).attr('src', live_snapshot_url) 
  img.src = live_snapshot_url
  
$(window).load ->
  refreshThumbnails()

