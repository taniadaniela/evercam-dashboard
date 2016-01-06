HideBrokenSnap = ->
  $('#message.snapshot-proxy').on 'error', ->
    @src = '/assets/offline.png'
    @removeclassName = 'snapshot-proxy snapshot-refresh'
    @className = 'no-thumbnail'
    true

window.initializeShared = ->
  HideBrokenSnap()