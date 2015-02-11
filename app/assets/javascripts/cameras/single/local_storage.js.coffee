window.localwidgetLoaded = false

initLocalStorage = ->
  window.localwidgetLoaded = true
  LocalStorage.options.cameraId = Evercam.Camera.id
  LocalStorage.options.api_id = Evercam.User.api_id
  LocalStorage.options.api_key = Evercam.User.api_key
  LocalStorage.Load()

handleTabOpen = ->
  $('.nav-tab-local-storage').on 'show.bs.tab', ->
    unless window.localwidgetLoaded
      initLocalStorage()

window.initializeLocalStorageTab = ->
  handleTabOpen()
