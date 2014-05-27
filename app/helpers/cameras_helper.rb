module CamerasHelper
  def get_evercam_api
    configuration = Rails.application.config
    parameters    = {logger: Rails.logger}
    if current_user
      parameters = parameters.merge(api_id: current_user.api_id,
                                    api_key: current_user.api_key)
    end
    settings      = {}
    begin
      settings = (configuration.evercam_api || {})
    rescue => error
      # Deliberately ignored.
    end
    parameters    = parameters.merge(settings) if !settings.empty?
    Evercam::API.new(parameters)
  end

  def preview(camera, live=false)
    proxy = "#{EVERCAM_API}cameras/#{camera['id']}/snapshot.jpg?api_id=#{current_user.api_id}&api_key=#{current_user.api_key}"
    begin
      res = get_evercam_api.get_latest_snapshot(camera['id'], true)
      if !res.nil?
         proxy     = "#{EVERCAM_API}cameras/#{camera['id']}/snapshot.jpg?api_id=#{current_user.api_id}&api_key=#{current_user.api_key}"
         uri       = URI::Data.new(res['data'])
         img_class = camera['is_online'] ? 'snap' : ''
         if live
           return "<img class='#{img_class}' data-proxy='#{proxy}' src='#{uri}' alt='Camera appears to be offline' width='100%' height='auto'>".html_safe
         else
           return "<img class='#{img_class}' data-proxy='#{proxy}' src='#{uri}' >".html_safe
         end
      end
    rescue => error
      Rails.logger.error "Exception caught processing preview request.\nCause: #{error}\n" +
                         error.backtrace.join("\n")
    end

    if live
      "<img class='live' src='#{proxy}' alt='Camera appears to be offline' width='100%' height='auto'>".html_safe
    else
      "<img class='live' src='#{proxy}' onerror=\"this.style.display='none'\" alt=''>".html_safe
    end
  end

end
