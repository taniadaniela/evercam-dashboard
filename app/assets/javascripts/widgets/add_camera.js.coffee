#= require jquery
#= require jquery_ujs
#= require bootstrap

Evercam_API_URL = 'https://api.evercam.io/v1/'
Dasboard_URL = 'https://dash.evercam.io'
API_ID = ''
API_Key = ''
iframeWindow = undefined

sortByKey = (array, key) ->
  array.sort (a, b) ->
    x = a[key]
    y = b[key]
    (if (x < y) then -1 else ((if (x > y) then 1 else 0)))

loadVendors = ->
  data = {}

  onError = (jqXHR, status, error) ->
    false

  onSuccess = (result, status, jqXHR) ->
    vendors = sortByKey(result.vendors, "name")
    for vendor in vendors
      $("#camera-vendor").append("<option value='#{vendor.id}'>#{vendor.name}</option>")

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    contentType: "application/json; charset=utf-8"
    type: 'GET'
    url: "#{Evercam_API_URL}vendors"

  jQuery.ajax(settings)
  true

loadVendorModels = (vendor_id) ->
  $("#camera-model option").remove()
  $("#camera-model").append('<option value="">Loading...</option>');
  if vendor_id is ""
    return

  data = {}
  data.vendor_id = vendor_id
  data.limit = 400

  onError = (jqXHR, status, error) ->
    false

  onSuccess = (result, status, jqXHR) ->
    $("#camera-model option").remove()
    if result.models.length == 0
      $("#camera-model").append('<option value="">No Model Found</option>');
      return

    models = sortByKey(result.models, "name")
    for model in models
      jpg_url = if model.defaults.snapshots then model.defaults.snapshots.jpg else ''
      if jpg_url is "unknown"
        jpg_url = ""
      $("#camera-model").append("<option jpg-val='#{jpg_url}' value='#{model.id}'>#{model.name}</option>")
    if $("#camera-model").find(":selected").attr("jpg-val") isnt 'Unknown'
      $("#camera-snapshot-url").val $("#camera-model").find(":selected").attr("jpg-val")
      $("#camera-snapshot-url").removeClass("invalid").addClass("valid")

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    contentType: "application/json; charset=utf-8"
    type: 'GET'
    url: "#{Evercam_API_URL}models.json"

  jQuery.ajax(settings)
  true

handleVendorModelEvents = ->
  $("#camera-vendor").on "change", ->
    loadVendorModels($(this).val())

  $("#camera-model").on "change", ->
    snapshot_url = $(this).find(":selected").attr("jpg-val")
    console.log snapshot_url
    if snapshot_url isnt 'Unknown'
      $("#camera-snapshot-url").val $(this).find(":selected").attr("jpg-val")

useAuthentication = ->
  $("#required-authentication").on 'click', ->
    if $(this).is(":checked")
      $("#authentication").removeClass("hide")
    else
      $("#authentication").addClass("hide")

handleInputEvents = ->
  $("#camera-url").on 'keyup', (e) ->
    if validate_hostname($(this).val())
      $(this).removeClass("invalid").addClass("valid")
    else
      $(this).removeClass("valid").addClass("invalid")
    validAllInformation()
  $("#camera-url").on 'focus', (e) ->
    $(".info-box .info-header").text("EXTERNAL IP / URL")
    $(".info-box .info-text").text("Please valid camera public IP or dydns domain.")
  $(".external-url").on 'click', ->
    $(".info-box .info-header").text("EXTERNAL IP / URL")
    $(".info-box .info-text").text("Please valid camera public IP or dydns domain.")

  $("#camera-port").on 'keyup', (e) ->
    if validateInt($(this).val())
      $(this).removeClass("invalid").addClass("valid")
    else
      $(this).removeClass("valid").addClass("invalid")
    validAllInformation()
  $("#camera-port").on 'focus', (e) ->
    $(".info-box .info-header").text("EXTERNAL PORT")
    $(".info-box .info-text").text("Default external port is 80.")
  $(".port").on 'click', ->
    $(".info-box .info-header").text("EXTERNAL PORT")
    $(".info-box .info-text").text("Default external port is 80.")

  $("#camera-snapshot-url").on 'keyup', (e) ->
    $(this).removeClass("invalid").addClass("valid")
    validAllInformation()
  $("#camera-snapshot-url").on 'focus', (e) ->
    $(".info-box .info-header").text("SNAPSHOT URL")
    $(".info-box .info-text").text("Please choose camera Vendor/Model to auto detect camera snapshot URL. If snapshot URL not found after select Vendor/Model you enter URL manual.")
  $(".snapshot-url").on 'click', ->
    $(".info-box .info-header").text("SNAPSHOT URL")
    $(".info-box .info-text").text("Please choose camera Vendor/Model to auto detect camera snapshot URL. If snapshot URL not found after select Vendor/Model you enter URL manual.")

  $("#camera-name").on 'keyup', (e) ->
    $(this).removeClass("invalid").addClass("valid")
  $("#camera-id").on 'keyup', (e) ->
    $(this).removeClass("invalid").addClass("valid")

  $("#user-email").on 'keyup', (e) ->
    if validateEmail($(this).val())
      $(this).removeClass("invalid").addClass("valid")
    else
      $(this).removeClass("valid").addClass("invalid")
  $("#user-password").on 'keyup', (e) ->
    $(this).removeClass("invalid").addClass("valid")
  $("#username").on 'keyup', (e) ->
    $(this).removeClass("invalid").addClass("valid")
  $(".default-username").on 'click', ->
    $("#camera-username").val('root')
  $(".default-password").on 'click', ->
    $("#camera-password").val('pass')

validate_hostname = (str) ->
  ValidIpAddressRegex = /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/
  ValidHostnameRegex = /^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$/
  ValidIpAddressRegex.test(str) or ValidHostnameRegex.test(str)

validateInt = (value) ->
  reg = /^(0|[0-9][1-9]|[1-9][0-9]*)$/
  reg.test value

validateEmail = (email) ->
  reg = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/
  #remove all white space from value before validating
  emailtrimed = email.replace(RegExp(' ', 'gi'), '')
  reg.test emailtrimed

validAllInformation = ->
  if $("#camera-port") is ''
    if $("#camera-url").hasClass('valid') && $("#camera-snapshot-url").hasClass('valid')
      $(".test-image").removeClass('hide')
      $(".help-texts").addClass('hide')
    else
      $(".test-image").addClass('hide')
      $(".help-texts").removeClass('hide')
  else
    if $("#camera-url").hasClass('valid') && $("#camera-port").hasClass('valid') && $("#camera-snapshot-url").hasClass('valid')
      $(".test-image").removeClass('hide')
      $(".help-texts").addClass('hide')
    else
      $(".test-image").addClass('hide')
      $(".help-texts").removeClass('hide')

testSnapshot = ->
  $("#test-snapshot").on 'click', ->
    port = $("#camera-port").val() unless $("#camera-port").val() is ''
    data = {}
    data.external_url = "http://#{$('#camera-url').val()}:#{port}"
    data.jpg_url = $('#camera-snapshot-url').val()
    data.cam_username = $("#camera-username").val() unless $("#camera-username").val() is ''
    data.cam_password = $("#camera-password").val() unless $("#camera-password").val() is ''

    onError = (jqXHR, status, error) ->
      $(".snapshot-msg").html(jqXHR.responseJSON.message)
      $(".snapshot-msg").show()

    onSuccess = (result, status, jqXHR) ->
      if result.status is 'ok'
        $("#testimg").attr('src', result.data)
        $(".snapshot-msg").hide()
        $("#test-snapshot").hide()
        $("#continue-step2").show()

    settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      contentType: "application/json; charset=utf-8"
      type: 'GET'
      url: "#{Evercam_API_URL}cameras/test"

    jQuery.ajax(settings)

handleContinueBtn = ->
  $("#continue-step2").on 'click', ->
    switchTab("camera-details", "camera-info")

  $("#continue-step3").on 'click', ->
    if $("#camera-name").val() is ''
      $("#camera-name").removeClass("valid").addClass("invalid")
      return
    if $("#camera-id").val() is ''
      $("#camera-id").removeClass("valid").addClass("invalid")
      return
    $("#camera-name").removeClass("invalid").addClass("valid")
    switchTab("camera-info", "user-create")

autoCreateCameraId = ->
  $("#camera-name").on 'keyup', ->
    $("#camera-id").val $(this).val().replace(RegExp(" ", "g"), "-").toLowerCase()

hasCameraInfo = ->
  if $("#camera-url").val() is '' && $("#camera-snapshot-url").val() is ''
    $("#camera-url").removeClass("valid").addClass("invalid")
    $("#camera-snapshot-url").removeClass("valid").addClass("invalid")
    switchTab("user-create", "camera-details")
    return false
  if $("#camera-name").val() is '' && $("#camera-id").val() is ''
    $("#camera-name").removeClass("valid").addClass("invalid")
    $("#camera-id").removeClass("valid").addClass("invalid")
    switchTab("user-create", "camera-info")
    return false
  true

autoLogInDashboard = () ->
  data = {
    'session[login]': $("#username").val()
    'session[password]': $("#user-password").val()
    'session[widget]': 'login-from-widget'
    'authenticity_token': $("#authenticity_token").val()
  }

  onError = (jqXHR, status, error) ->
    false
  onSuccess = (result, status, jqXHR) ->
    parent.location.href = "#{Dasboard_URL}"
    true

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    contentType: "application/x-www-form-urlencoded"
    type: 'POST'
    url: "#{Dasboard_URL}/sessions"

  jQuery.ajax(settings)

createUserAccount = ->
  $("#create-account").on 'click', ->
    if $("#username").val() is ''
      $("#username").removeClass("valid").addClass("invalid")
      return
    if $("#user-email").val() is '' || !validateEmail($("#user-email").val())
      $("#user-email").removeClass("valid").addClass("invalid")
      return
    if $("#user-password").val() is ''
      $("#user-password").removeClass("valid").addClass("invalid")
      return
    if !hasCameraInfo()
      return

    if API_ID isnt '' && API_Key isnt ''
      createCamera(API_ID, API_Key)
      return

    data = {}
    data.firstname = $("#username").val()
    data.lastname = $("#username").val()
    data.username = $("#username").val()
    data.country = 'IR'
    data.email = $("#user-email").val()
    data.password = $("#user-password").val()

    onError = (jqXHR, status, error) ->
      $("#message-user-create").text(jqXHR.responseJSON.message)
      $("#message-user-create").removeClass("hide")

    onSuccess = (result, status, jqXHR) ->
      getAPICredentials()

    settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      contentType: "application/x-www-form-urlencoded"
      type: 'POST'
      url: "#{Evercam_API_URL}users"

    jQuery.ajax(settings)

getAPICredentials = ->
  data = {}
  data.password = $("#user-password").val()

  onError = (jqXHR, status, error) ->
    false

  onSuccess = (result, status, jqXHR) ->
    API_ID = result.api_id
    API_Key = result.api_key
    createCamera(result.api_id, result.api_key)

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    contentType: "application/json; charset=utf-8"
    type: 'GET'
    url: "#{Evercam_API_URL}users/#{$("#user-email").val()}/credentials"

  jQuery.ajax(settings)

createCamera = (api_id, api_key) ->
  data = {}
  data.id = $("#camera-id").val()
  data.name = $("#camera-name").val()
  data.vendor = $("#camera-vendor").val()
  data.model = $('#camera-model').val()
  data.is_public = false
  data.cam_username = $("#camera-username").val() unless $("#camera-username").val() is ''
  data.cam_password = $("#camera-password").val() unless $("#camera-password").val() is ''
  data.external_host = $("#camera-url").val()
  data.external_http_port = $("#camera-port").val() unless $("#camera-port").val() is ''
  data.jpg_url = $("#camera-snapshot-url").val()

  onError = (jqXHR, status, error) ->
    $("#message-camera-info").text(jqXHR.responseJSON.message)
    $("#message-camera-info").removeClass("hide")
    $("#message-user-create").addClass("hide")

  onSuccess = (result, status, jqXHR) ->
    autoLogInDashboard()

  onDuplicateError = (xhr) ->
    switchTab("user-create", "camera-info")
    $("#message-camera-info").text(xhr.responseText.message)
    $("#message-camera-info").removeClass("hide")
    $("#message-user-create").addClass("hide")

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    statusCode: {409: onDuplicateError },
    contentType: "application/x-www-form-urlencoded"
    type: 'POST'
    url: "#{Evercam_API_URL}cameras?api_id=#{api_id}&api_key=#{api_key}"

  jQuery.ajax(settings)

clearForm = ->
  $("#camera-id").val('')
  $("#camera-id").removeClass('valid').removeClass("invalid")
  $("#camera-name").val('')
  $("#camera-name").removeClass('valid').removeClass("invalid")
  $("#user-email").val('')
  $("#user-email").removeClass('valid').removeClass("invalid")
  $("#username").val('')
  $("#username").removeClass('valid').removeClass("invalid")
  $("#user-password").val('')
  $("#user-password").removeClass('valid').removeClass("invalid")
  $("#camera-username").val('')
  $("#camera-password").val('')
  $("#camera-port").val('')
  $("#camera-port").removeClass('valid').removeClass("invalid")
  $("#camera-url").val('')
  $("#camera-url").removeClass('valid').removeClass("invalid")
  $("#camera-snapshot-url").val('')
  $("#camera-snapshot-url").removeClass('valid').removeClass("invalid")
  $("#camera-vendor").val('')
  $("#camera-model option").remove()
  $("#camera-model").append('<option value="">Unknown</option>');
  switchTab("user-create", "camera-details")
  $("#required-authentication").removeAttr("checked")
  $("#authentication").addClass("hide")
  $("#message-camera-info").addClass("hide")
  $("#message-user-create").addClass("hide")
  $("#testimg").attr('src', '')
  $(".snapshot-msg").hide()
  $("#test-snapshot").show()
  $("#continue-step2").hide()
  API_ID = ''
  API_Key = ''

onClickTabs = ->
  $(".nav-steps li").on 'click', ->
    previousTab = $(".nav-steps li.active").attr("href")
    $(".nav-steps li").removeClass('active')
    currentTab = $(this).attr("href")
    $(this).addClass('active')
    $("#{previousTab}").fadeOut(300, ->
      $("#{currentTab}").fadeIn(300)
    )

switchTab = (hideTab, showTab) ->
  $(".nav-steps li").removeClass('active')
  $("##{hideTab}").fadeOut(300, ->
    $("##{showTab}").fadeIn(300)
  )
  $("#li-#{showTab}").addClass('active')

initAddCamera = ->
  url = window.location.origin
  embedCode = '&lt;div evercam&#61;"add-camera-public"&gt;&lt;&#47;div&gt;' + '&lt;script type&#61;"text/javascript" src&#61;"' + url + '&#47;widgets/add.camera.js"&gt;&lt;&#47;script&gt;'
  $('#code').html embedCode
  $('.placeholder').empty()
  iframe = jQuery('<iframe />').css(
    'overflow': 'hidden'
    'width': '100%'
    'height': '420px').attr(
    'src': '/widgets/cameras/public/add'
    'frameborder': '0'
    scrolling: 'no').appendTo('.placeholder')
  return

resizeIframe = (iframeControl) ->
  iframeWindow = iframeControl
  iframeControl.style.height = iframeControl.contentWindow.document.body.scrollHeight + 'px'
  return

handleWindowResize = ->
  $(window).resize ->
  if !iframeWindow
    return
  resizeIframe iframeWindow
  return

window.initializeAddCameraPublic = ->
  useAuthentication()
  loadVendors()
  handleVendorModelEvents()
  handleInputEvents()
  testSnapshot()
  handleContinueBtn()
  createUserAccount()
  onClickTabs()

window.initializeAddCamera = ->
  initAddCamera();
  $("#code").on "click", ->
    this.select();
  handleWindowResize()