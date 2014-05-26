TIMEOUT = 5
begin
   settings    = EvercamDashboard::Application.config.evercam_api
   scheme      = (settings[:scheme] || "https")
   host        = (settings[:host] || "api.evercam.io")
   host        = "#{host}:#{settings[:port]}" if settings.include?(:port)
   EVERCAM_API = "#{scheme}://#{host}/v1/"
rescue
   EVERCAM_API = 'https://api.evercam.io/v1/'
end