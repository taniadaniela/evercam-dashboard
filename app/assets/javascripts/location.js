function initialize() {
  if (cameraLong === '') {
    $('#map-canvas').replaceWith("<p>The location of this camera was not found</p>");
    return;
  }
  var cameraLatlng = new google.maps.LatLng(cameraLat, cameraLong);
  var mapOptions = {
    zoom: 8,
    center: cameraLatlng
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
google.maps.event.addDomListener(window, 'load', initialize);