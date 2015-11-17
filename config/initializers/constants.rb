TIMEOUT = 5
begin
  EVERCAM_API       = evercam_api_url
  EVERCAM_MEDIA_API = evercam_media_api_url
rescue
  EVERCAM_API       = 'https://api.evercam.io/v1/'
  EVERCAM_MEDIA_API = 'https://media.evercam.io/v1/'
end

def evercam_api_url
  settings    = EvercamDashboard::Application.config.evercam_api
  scheme      = (settings[:scheme] || "https")
  host        = (settings[:host] || "api.evercam.io")
  host        = "#{host}:#{settings[:port]}" if settings.include?(:port)
  "#{scheme}://#{host}/v1/"
end

def evercam_media_api_url
  settings    = EvercamDashboard::Application.config.evercam_media_api
  scheme      = (settings[:scheme] || "https")
  host        = (settings[:host] || "media.evercam.io")
  host        = "#{host}:#{settings[:port]}" if settings.include?(:port)
  "#{scheme}://#{host}/v1/"
end
