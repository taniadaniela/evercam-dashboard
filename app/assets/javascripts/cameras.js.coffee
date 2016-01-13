window.showFeedback = (message) ->
  Notification.show(message)
  true

refreshImages = ->
  clearPreviousTime = 0
  $('img.snap').each ->
    oldimg = $(this)
    $("<img class='snap' />").attr({"data-proxy": $(this).attr('data-proxy'), "src": $(this).attr('data-proxy') + '&' + new Date().getTime()}).load () ->
      if this.complete and this.naturalWidth isnt undefined and this.naturalWidth isnt 0
        oldimg.replaceWith($(this))
        clearTimeout clearPreviousTime
        clearPreviousTime = setTimeout (->
          $(".refresh-images i").removeClass "rotate-refresh-icon"
        ), 4000

onRefreshImage = ->
  $(".refresh-images").on 'click', () ->
    $(this).find('i').removeClass("rotate-refresh-icon").addClass "rotate-refresh-icon"
    refreshImages()

handlePusherEventIndex = ->
  channel = Evercam.Pusher.subscribe(Evercam.User.username)
  channel.bind 'user_cameras_changed', (data) ->
    $('#camera-index.page-content').load "#{Evercam.request.rootpath} #camera-index.page-content > *", ->
      hideOfflineCamerasBox()
      window.refreshThumbnails()

initNotification = ->
  Notification.init(".bb-alert");
  if notifyMessage
    Notification.show notifyMessage

window.initializeCameraIndex = ->
  Metronic.init()
  Layout.init()
  QuickSidebar.init()
  initNotification()
  refreshImages()
  onRefreshImage()
  handlePusherEventIndex()
  $('[data-toggle="tooltip"]').tooltip()
