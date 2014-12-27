validate_hostname= (str) ->
  ValidIpAddressRegex = /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/
  ValidHostnameRegex = /^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$/
  ValidIpAddressRegex.test(str) || ValidHostnameRegex.test(str)

showFeedback = (message) ->
  Notification.show(message)
  true

$ ->
  $('#camera-url-web').on('input', () ->
    val = $(this).val()
    a = document.createElement('a')
    a.href = val
    $(this).val(a.hostname)
    $('#port-web').val(a.port)
    $('#snapshot-web').val(a.pathname)
  )

  $('#test').click((e) ->
    intRegex = /^\d+$/
    port = $('#port').val()
    ext_url = $('#camera-url').val()
    $snap = $('#snapshot')
    jpg_url = $snap.val()
    # Auto-fix snapshot
    if (jpg_url.indexOf('/') == 0)
      $snap.val(jpg_url.substring(1))
      jpg_url = $snap.val()


    # Encode parameters
    jpg_url = jpg_url.replace(/\?/g, 'X_QQ_X').replace(/&/g, 'X_AA_X')
    e.preventDefault();
    # Validate port
    if(port != '' && (!intRegex.test(port) || port > 65535))
      showFeedback("Port value is incorrect")
      return
    else if (port != '')
      port = ':' + port

    # Validate host
    if (ext_url == '' || !validate_hostname(ext_url))
      showFeedback("External IP Address (or URL) is incorrect")
      return
    else if (ext_url.indexOf('192.168') == 0 || ext_url.indexOf('127.0.0') == 0 || ext_url.indexOf('10.') == 0)
      showFeedback("This is the Internal IP. Please use the External IP.")
      return

    params = ['external_url=http://' + ext_url + port,
              'jpg_url=/' + jpg_url,
              'cam_username=' + $('#camera-username').val(),
              'cam_password=' + $('#camera-password').val()]

    l = Ladda.create(this);
    l.start();
    progress = 0;
    interval = setInterval( ->
      progress = Math.min(progress + 0.025, 1);
      l.setProgress(progress);
      if (progress == 1)
        l.stop()
        clearInterval(interval)
    , 200);

    $.getJSON(EVERCAM_API + 'cameras/test.json?' + params.join('&'))
    .done((resp) ->
      console.log('success')
      if (resp.data.indexOf('data:text/html') == 0)
        showFeedback("We got a response, but it's not an image")
      else
        showFeedback("We got a snapshot")
        $('#testimg').attr('src', resp.data)
    )
    .fail((resp) ->
      $('#test-error').text(resp.responseJSON.message)
      console.log('error')
    )
    .always(() ->
      l.stop()
      clearInterval(interval)
    )
  )
