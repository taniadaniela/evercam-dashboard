loadMap = ->
  options =
    zoom: 2
    center: new (google.maps.LatLng)(25, 10)
    mapTypeId: google.maps.MapTypeId.TERRAIN
    mapTypeControl: false
  # init map
  map = new (google.maps.Map)(document.getElementById('map-canvas'), options)

  Evercam.Cameras.forEach (camera) ->
    marker = new google.maps.Marker({
      position: new google.maps.LatLng(camera.location.lat, camera.location.lng),
      map: map,
      icon: iconBase(camera.is_online),
      title: 'Click Me '
    })
    do (marker) ->
      google.maps.event.addListener marker, 'click', ->
        infowindow = new (google.maps.InfoWindow)(content:
          "<table class='table table-striped'>
            <tbody>
              <tr>
                <th></th>
                <td>#{thumbnailTag(camera.thumbnail_url)}<br/><br/>
                  <div class='center'>
                    <strong>
                      #{camera.name}
                      <a href='https://dash.evercam.io/v1/cameras/#{camera.id}/live' target='_blank'>
                      <i class='fa fa-external-link'></i>
                      </a>
                    </strong>
                  </div>
                </td>
              </tr>
              <tr>
                <th>Data Processor</th>
                <td>Camba.tv Ltd. 01-5383333</td>
              </tr>
              <tr>
                <th>Data Controller</th>
                <td>#{camera.owner}</td>
              </tr>
              <tr>
                <th>Online ?</th>
                <td>#{humanizeStatus(camera.is_online)}</td>
              </tr>
              <tr>
                <th>Public ?</th>
                <td>#{humanizeStatus(camera.is_public)}</td>
              </tr>
              <tr>
                <th>Vendor/Model</th>
                <td>#{vendorLogo(camera.vendor_id)} / #{camera.vendor_name}</td>
              </tr>
            </tbody>
          </table>")
        infowindow.open map, marker
        return
      return

vendorLogo = (vendorId) ->
  if vendorId == ''
    "Other"
  else
    "<img width='80' src='http://evercam-public-assets.s3.amazonaws.com/#{vendorId}/logo.jpg' />"

iconBase = (status) ->
  if status == false
    'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%E2%80%A2|808080'
  else
    ''

humanizeStatus = (status) ->
  if status == true
    "Yes"
  else
    "No"

thumbnailTag = (url) ->
  "<img height='140' src='#{url}'/>"

window.initializeMap = ->
  loadMap()
