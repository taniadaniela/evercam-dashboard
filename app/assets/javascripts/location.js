function initialize() {
  if (cameraLong === '') {
    $('#map-canvas').replaceWith("<p>The location of this camera was not found. You can set the location in the Settings tab.</p>");
    return;
  }
  var cameraLatlng = new google.maps.LatLng(cameraLat, cameraLong);
  var mapOptions = {
    zoom: 13,
    center: cameraLatlng,
    mapTypeControl: false,
    streetViewControl: false
  }
  var map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);

  var marker = new google.maps.Marker({
    position: cameraLatlng,
    map: map,
    title: 'Camera Location'
  });

  var mapFirstClick = false;
  $("#nav-tabs").click(function() {
    mapFirstClick || setTimeout(function() {
      google.maps.event.trigger(map, 'resize');
      mapFirstClick = true;
      map.setCenter(cameraLatlng);
    }, 200);
  });

}
window.onload = initialize;

// Handle sidebar menu
var handleSidebarMenu = function () {
  jQuery('.page-sidebar').on('click', 'li > a', function (e) {

    if ($(this).next().hasClass('sub-menu') === false) {
      if (Metronic.getViewPort().width < 992) { // close the menu on mobile view while laoding a page
        $('.page-header .responsive-toggler').click();
      }
      return;
    }

    if ($(this).next().hasClass('sub-menu always-open')) {
      return;
    }

    var parent = $(this).parent().parent();
    var the = $(this);
    var menu = $('.page-sidebar-menu');
    var sub = jQuery(this).next();

    var autoScroll = menu.data("auto-scroll");
    var slideSpeed = parseInt(menu.data("slide-speed"));

    parent.children('li.open').children('a').children('.arrow').removeClass('open');
    parent.children('li.open').children('.sub-menu:not(.always-open)').slideUp(slideSpeed);
    parent.children('li.open').removeClass('open');

    var slideOffeset = -200;

    if (sub.is(":visible")) {
      jQuery('.arrow', jQuery(this)).removeClass("open");
      jQuery(this).parent().removeClass("open");
      sub.slideUp(slideSpeed, function () {
        if (autoScroll == true && $('body').hasClass('page-sidebar-closed') == false) {
          if ($('body').hasClass('page-sidebar-fixed')) {
            menu.slimScroll({
              'scrollTo': (the.position()).top
            });
          } else {
            Metronic.scrollTo(the, slideOffeset);
          }
        }
        handleSidebarAndContentHeight();
      });
    } else {
      jQuery('.arrow', jQuery(this)).addClass("open");
      jQuery(this).parent().addClass("open");
      sub.slideDown(slideSpeed, function () {
        if (autoScroll == true && $('body').hasClass('page-sidebar-closed') == false) {
          if ($('body').hasClass('page-sidebar-fixed')) {
            menu.slimScroll({
              'scrollTo': (the.position()).top
            });
          } else {
            Metronic.scrollTo(the, slideOffeset);
          }
        }
        handleSidebarAndContentHeight();
      });
    }

    e.preventDefault();
  });
}();
