imagesCompare = undefined

window.sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = $.ajax(settings)

initCompare = ->
  imagesCompareElement = $('.js-img-compare').imagesCompare()
  imagesCompare = imagesCompareElement.data('imagesCompare')
  events = imagesCompare.events()

  imagesCompare.on events.changed, (event) ->
    true

  $('.js-front-btn').on 'click', (event) ->
    event.preventDefault()
    imagesCompare.setValue 1, true

  $('.js-back-btn').on 'click', (event) ->
    event.preventDefault()
    imagesCompare.setValue 0, true

  $('.js-toggle-btn').on 'click', (event) ->
    event.preventDefault()
    if imagesCompare.getValue() >= 0 and imagesCompare.getValue() < 1
      imagesCompare.setValue 1, true
    else
      imagesCompare.setValue 0, true

getFirstLastImages = (image_id, query_string, reload) ->
  data =
    api_id: Evercam.User.api_id
    api_key: Evercam.User.api_key

  onError = (jqXHR, status, error) ->
    false

  onSuccess = (response, status, jqXHR) ->
    snapshot = response
    if query_string.indexOf("nearest") > 0 && response.snapshots.length > 0
      snapshot = response.snapshots[0]
    if snapshot.data isnt undefined
      $("##{image_id}").attr("src", snapshot.data)
      initCompare() if reload
    else
      Notification.show("No image found")

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    type: 'GET'
    url: "#{Evercam.API_URL}cameras/#{Evercam.Camera.id}/recordings/snapshots#{query_string}"
  sendAJAXRequest(settings)

handleTabOpen = ->
  $('.nav-tab-compare').on 'shown.bs.tab', ->
    initCompare()
    updateURL()

datePickerSelect = (dp, $input) ->
  getFirstLastImages("compare_before", "/#{(new Date($input.val())) / 1000}/nearest")

updateURL = ->
  url = "#{Evercam.request.rootpath}/compare"
  query_string = ""
  if $("#txtbefore").val() isnt ""
    query_string = "?before=#{moment.utc($("#txtbefore").val()).toISOString()}"
  if $("#txtafter").val() isnt ""
    if query_string is ""
      query_string = "?after=#{moment.utc($("#txtafter").val()).toISOString()}"
    else
      query_string = "#{query_string}&after=#{moment.utc($("#txtafter").val()).toISOString()}"

  url = "#{url}#{query_string}"
  if history.replaceState
    window.history.replaceState({}, '', url)

getQueryStringByName = (name) ->
  name = name.replace(/[\[]/, '\\[').replace(/[\]]/, '\\]')
  regex = new RegExp('[\\?&]' + name + '=([^&#]*)')
  results = regex.exec(location.search)
  if results == null
    null
  else
    decodeURIComponent(results[1].replace(/\+/g, ' '))

clickOnEmbed = ->
  $(".images-compare-embed-code").on "click", ->
    if !Evercam.Camera.is_public
      Notification.show("Embedding is not working for private cameras.")
    after = getQueryStringByName("after")
    before = getQueryStringByName("before")
    after = "" if after is null
    before = "" if before is null
    $("#txtEmbedCode").val("<div id='evercam-compare'></div><script src='#{window.location.origin}/assets/evercam_compare.js' class='#{Evercam.Camera.id} #{before} #{after}'></script>")
    $("#txtEmbedCode").select();
    copyToClipboard(document.getElementById("txtEmbedCode"))

copyToClipboard = (elem) ->
  targetId = '_hiddenCopyText_'
  isInput = elem.tagName == 'INPUT' or elem.tagName == 'TEXTAREA'
  origSelectionStart = undefined
  origSelectionEnd = undefined
  if isInput
    target = elem
    origSelectionStart = elem.selectionStart
    origSelectionEnd = elem.selectionEnd
  else
    target = document.getElementById(targetId)
    if !target
      target = document.createElement('textarea')
      target.style.position = 'absolute'
      target.style.left = '-9999px'
      target.style.top = '0'
      target.id = targetId
      document.body.appendChild target
    target.textContent = elem.textContent
  currentFocus = document.activeElement
  target.focus()
  target.setSelectionRange 0, target.value.length
  succeed = undefined
  try
    succeed = document.execCommand('copy')
  catch e
    succeed = false
  if currentFocus and typeof currentFocus.focus == 'function'
    currentFocus.focus()
  if isInput
    elem.setSelectionRange origSelectionStart, origSelectionEnd
  else
    target.textContent = ''
  succeed

window.initializeCompareTab = ->
  $("#txtEmbedCode").val("<div id='evercam-compare'></div><script src='#{window.location.origin}/assets/evercam_compare.js' class='#{Evercam.Camera.id}'></script>")
  getFirstLastImages("compare_before", "/oldest", false)
  getFirstLastImages("compare_after", "/latest", false)
  handleTabOpen()
  clickOnEmbed()
  $('#calendar-before').datetimepicker
    format: 'm/d/Y H:m'
    onSelectTime: (dp, $input) ->
      $("#txtbefore").val($input.val())
      val = getQueryStringByName("after")
      url = "#{Evercam.request.rootpath}/compare?before=#{moment.utc($input.val()).toISOString()}"
      if val isnt null
        url = "#{url}&after=#{val}"
      if history.replaceState
        window.history.replaceState({}, '', url)
      getFirstLastImages("compare_before", "/#{(new Date($input.val())) / 1000}/nearest", true)

  $('#calendar-after').datetimepicker
    format: 'm/d/Y H:m'
    onSelectTime: (dp, $input) ->
      $("#txtafter").val($input.val())
      val = getQueryStringByName("before")
      url = "#{Evercam.request.rootpath}/compare"
      if val isnt null
        url = "#{url}?before=#{val}&after=#{moment.utc($input.val()).toISOString()}"
      else
        url = "#{url}?after=#{moment.utc($input.val()).toISOString()}"
      if history.replaceState
        window.history.replaceState({}, '', url)
      getFirstLastImages("compare_after", "/#{(new Date($input.val())) / 1000}/nearest", true)