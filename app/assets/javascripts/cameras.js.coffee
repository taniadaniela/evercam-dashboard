showFeedback = (message) ->
  Notification.show(message)
  true

$ ->
  $('img.live').on 'error', () ->
    showFeedback("Error loading camera image. Camera might be offline.")
    console.log('Error loading camera image. Camera might be offline.')

  $('img.snap').each ->
    oldimg = $(this)
    $("<img />").attr('src', $(this).attr('data-proxy') + '&' + new Date().getTime()).load () ->
      if not this.complete or this.naturalWidth is undefined or this.naturalWidth is 0
        showFeedback('Error loading camera image. Camera might be offline.')
        console.log('camera offline')
      else
        oldimg.replaceWith($(this))
