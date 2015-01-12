module CamerasHelper
  def preview(camera, live=false)
    preview = camera['thumbnail']
    proxy = "#{EVERCAM_API}cameras/#{camera['id']}/snapshot.jpg?api_id=#{current_user.api_id}&api_key=#{current_user.api_key}"
    begin
      if preview.nil? or preview == ""
        res = get_evercam_api.get_latest_snapshot(camera['id'], true)
        unless res.nil?
          uri = URI::Data.new(res['data'])
          img_class = camera['is_online'] ? 'snap' : ''
          if live
            return "<img class='#{img_class}' data-proxy='#{proxy}' src='#{uri}' width='100%' height='auto'>".html_safe
          else
            return "<img class='#{img_class}' data-proxy='#{proxy}' src='#{uri}' >".html_safe
          end
        end
      else
        uri = URI::Data.new(preview)
        img_class = camera['is_online'] ? 'snap' : ''
        if live
          return "<img class='#{img_class}' data-proxy='#{proxy}' src='#{uri}' width='100%' height='auto'>".html_safe
        else
          return "<img class='#{img_class}' data-proxy='#{proxy}' src='#{uri}' >".html_safe
        end
      end
    rescue => error
      Rails.logger.error "Exception caught processing preview request.\nCause: #{error}\n" +
                         error.backtrace.join("\n")
    end

    if live
      "<img class='live' src='#{proxy}' width='100%' height='auto'>".html_safe
    else
      "<img class='live' src='#{proxy}' onerror=\"this.style.display='none'\" alt=''>".html_safe
    end
  end
end
