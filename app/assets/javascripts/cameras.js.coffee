showFeedback = (message) ->
  Notification.show(message)
  true

refreshImages = ->
  $('img.snap').each ->
    oldimg = $(this)
    $("<img class='snap' />").attr({"data-proxy": $(this).attr('data-proxy'), "src": $(this).attr('data-proxy') + '&' + new Date().getTime()}).load () ->
      if this.complete and this.naturalWidth isnt undefined and this.naturalWidth isnt 0
        oldimg.replaceWith($(this))

onRefreshImage = ->
  $(".refresh-images").on 'click', () ->
    refreshImages()
  true

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
