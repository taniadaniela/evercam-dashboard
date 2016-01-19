HideBrokenSnap = ->
  $('#message.snapshot-proxy').on 'error', ->
    @src = '/assets/offline.png'
    @removeclassName = 'snapshot-proxy snapshot-refresh'
    @className = 'no-thumbnail'
    true

OpenIntercom = ->
  $("#FeedBack_intercom").on "click", ->
    $('#intercom-launcher').removeClass('intercom-launcher-active').addClass('intercom-launcher-inactive')
    $('#intercom-messenger').removeClass('intercom-messenger-inactive').addClass('intercom-messenger-active')
    $('#intercom-conversations').addClass('intercom-sheet-active')

window.initializeHeader = ->
  HideBrokenSnap()
  OpenIntercom()
