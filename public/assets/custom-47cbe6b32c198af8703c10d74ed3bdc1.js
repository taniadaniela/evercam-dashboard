$(function () {
  var previous;
  $('#camera-vendor').one('focus', function() {
    previous = this.value;
  }).on('change', function() {
    $('#camera-model' + previous).addClass('hidden');
    $('#camera-model' + this.value).removeClass('hidden');
    previous = this.value;
  });

  // Javascript to enable link to tab
  var url = document.location.toString();
  if (url.match('#')) {
    $('.nav-tabs a[href=#'+url.split('#')[1]+']').tab('show');
    setTimeout(function() {scrollTo(0,0)}, 10);
  }

  // Change hash for page-reload
  $('.nav-tabs a').on('shown.bs.tab', function (e) {
    window.location.hash = e.target.hash;
    scrollTo(0,0);
  })

  $( "#additional" ).click(function() {
    $( "#settings" ).slideToggle( "slow", function() {});
  });

});
// TOOLTIP HOVER
$(function () {
  $('body').popover({
    selector: '[data-toggle="popover"]'
  });

  $('body').tooltip({
    selector: 'a[rel="tooltip"], [data-toggle="tooltip"]'
  });


  // TEST SNAPSHOT
  $('#test').click(function(e) {
    var params = ['external_url=http://' + $('#camera-url').val() + ':' + $('#port').val(), 'jpg_url=' + $('#snapshot').val(),
      'cam_username=' + $('#camera-username').val(), 'cam_password=' + $('#camera-password').val()];
    e.preventDefault();
    var l = Ladda.create(this);
    l.start();
    var progress = 0;
    var interval = setInterval( function() {
      progress = Math.min( progress + 0.025, 1 );
      l.setProgress( progress );

      if( progress === 1 ) {
        l.stop();
        clearInterval( interval );
      }
    }, 200 );
    $.getJSON('https://dashboard.evercam.io/v1/cameras/test.json?' + params.join('&'))
      .done(function(resp) {
        console.log('success');
        $('#testimg').attr('src', resp.data);
      })
      .fail(function(resp) {
        $('#test-error').text(resp.responseJSON.message);
        console.log('error');
      })
      .always(function() {
        l.stop();
        clearInterval( interval );
      });
  });

// TOGGLE ADDITIONAL ADD CAMERA SETTINGS
  $( "#additional" ).click(function() {
    $( "#settings" ).slideToggle( "slow", function() {});
  });

  var previous;
  $('#camera-vendor').one('focus', function() {
    previous = this.value;
  }).on('change', function() {
    $('#camera-model' + previous).addClass('hidden');
    $('#camera-model' + this.value).removeClass('hidden');
    previous = this.value;
  });

  $.validate();
});
