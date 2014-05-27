if !window.Evercam
  window.Evercam = {}

$ ->
  #Replace Broken Image
  $('img').error( ->
    $(this).attr('src', 'https://www.evercam.io/img/publiccams-error.png')
  )