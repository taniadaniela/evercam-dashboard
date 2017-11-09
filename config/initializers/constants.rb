TIMEOUT = 5

def evercam_media_api_url
  settings    = EvercamDashboard::Application.config.evercam_media_api
  scheme      = (settings[:scheme] || "https")
  host        = (settings[:host] || "newmedia.evercam.io")
  host        = "#{host}:#{settings[:port]}" if settings.include?(:port)
  "#{scheme}://#{host}/v1/"
end

begin
  EVERCAM_API       = evercam_media_api_url
  EVERCAM_MEDIA_API = evercam_media_api_url
rescue
  EVERCAM_API       = 'https://newmedia.evercam.io/v1/'
  EVERCAM_MEDIA_API = 'https://newmedia.evercam.io/v1/'
end
