def cameras_stubs(user)
  stub_request(:post, "#{EVERCAM_API}cameras.json").
    to_return(:status => 200, :body => '{"cameras": [{"id": "testcam", "name": "Test Camera"}]}', :headers => {})

  stub_request(:get, "#{EVERCAM_API}cameras/testcam.json?api_id=#{user.api_id}&api_key=#{user.api_key}&thumbnail=true").
    to_return(:status => 200, :body => '{"cameras": [{"name": "Test Camera", "id": "testcam", "rights": "edit", "owner":"'+user.username+'",
      "vendor": null,
      "vendor_name": null,
      "model": null,
      "created_at": 1394104528,
      "updated_at": 1402326199,
      "last_polled_at": 1402326198,
      "last_online_at": 1402326198,
      "timezone": "Etc/GMT0",
      "is_online": true,
      "is_public": false,
      "external_host": "media.lintvnews.com",
      "internal_host": "",
      "external_http_port": 80,
      "internal_http_port": "",
      "external_rtsp_port": "",
      "internal_rtsp_port": "",
      "jpg_url": "/BTI/KXAN07.jpg",
      "rtsp_url": "",
      "cam_username": "",
      "cam_password": "",
      "mac_address": null,
      "location": null,
      "discoverable": false,
      "external": {
        "jpg_url": "http://media.lintvnews.com/BTI/KXAN07.jpg",
        "rtsp_url": "rtsp://media.lintvnews.com"
      },
      "internal": {
        "jpg_url": null,
        "rtsp_url": null
      },
      "dyndns": {
        "jpg_url": "http://austin2.evr.cm/BTI/KXAN07.jpg",
        "rtsp_url": "rtsp://austin2.evr.cm:"
      },
      "short": {
        "jpg_url": "http://evr.cm/austin2.jpg"
      },
      "owned": true}]}', :headers => {})

  stub_request(:get, "#{EVERCAM_API}shares/cameras/testcam.json?api_id=#{user.api_id}&api_key=#{user.api_key}").
    to_return(:status => 200, :body => '{"shares": []}', :headers => {})

  stub_request(:get, "#{EVERCAM_API}users/#{user.username}/cameras.json?api_id=#{user.api_id}&api_key=#{user.api_key}&include_shared=true&thumbnail=true").
    to_return(:status => 200, :body => {:cameras => [{:id => 'testcam', :name => 'Test Camera', :rights => 'edit'}]}.to_json, :headers => {})

  stub_request(:get, "#{EVERCAM_API}users/#{user.username}/cameras.json?api_id=#{user.api_id}&api_key=#{user.api_key}&include_shared=false&thumbnail=true").
    to_return(:status => 200, :body => '{"cameras": []}', :headers => {})

  stub_request(:get, "#{EVERCAM_API}shares/requests/testcam.json?api_id=#{user.api_id}&api_key=#{user.api_key}&status=PENDING").
    to_return(:status => 200, :body => '{"share_requests": []}', :headers => {})

  stub_request(:get, "#{EVERCAM_API}shares.json?api_id=#{user.api_id}&api_key=#{user.api_key}&camera_id=testcam&user_id=#{user.username}").
    to_return(:status => 200, :body => '{"shares": [{}]}', :headers => {})

  stub_request(:get, "#{EVERCAM_API}cameras/testcam/logs.json?api_id=#{user.api_id}&api_key=#{user.api_key}&objects=true&page=-1&types=").
    to_return(:status => 200, :body => '{"logs": [], "pages": 1}', :headers => {})

  stub_request(:get, "#{EVERCAM_API}cameras/testcam/snapshots/latest.json?api_id=#{user.api_id}&api_key=#{user.api_key}&with_data=true").
    to_return(:status => 200, :body => '{"snapshots": []}', :headers => {})

  stub_request(:post, "#{EVERCAM_API}cameras/testcam/snapshots.json").
    with(:body => {"api_id"=>"#{user.api_id}", "api_key"=>"#{user.api_key}", "notes"=>"Initial snapshot"},
         :headers => {'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Faraday v0.9.0'}).
    to_return(:status => 200, :body => '{"snapshots": [{"camera": "aaaa11123","notes": null,"created_at": 1401205738,"timezone": "Etc/UTC"}]}', :headers => {})

end