setVideoContainerHeight = ->
	$('#evercam-video-section').css 'width', '100%'
	$('#evercam-video-section video').css 'min-width', '100%'
	$('#evercam-video-section').css 'height', $(window).innerHeight()
	$('#evercam-video-section video').css 'min-height', '100%'

resizeWin = ->
	$(window).resize ->
	  $('#evercam-video-section').css height: $(window).innerHeight()
	  centerSignIn()
	  setVideoContainerHeight()
	  return

centerSignIn = ->
  offset = ($(window).height() - $('.section-position').height()) / 2
  if $(window).height() > $('.section-position').height()
    # Center vertically in window
    $('.section-position').css "margin-top", offset

  widthset = ($(window).width() - $('.center-div').width()) / 2
  if $(window).width() > $('.center-div').width()
    # Center vertically in window
    $('.center-div').css "margin-left", widthset

window.initializeSignInUp = ->
	setVideoContainerHeight()
	centerSignIn()
	resizeWin()