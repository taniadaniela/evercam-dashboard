module CamerasHelper
  def preview(camera, live=false)
    res = API_call("cameras/#{camera['id']}/snapshots/latest.json", :get, {}, {:with_data => true})
    proxy = "#{EVERCAM_API}cameras/#{camera['id']}/snapshot.jpg?api_id=#{current_user.api_id}&api_key=#{current_user.api_key}"
    if res.success?
      snapshots = JSON.parse(res.body)['snapshots']
      unless snapshots.empty?
        uri = URI::Data.new(snapshots[0]['data'])
        img_class = camera['is_online'] ? 'snap' : ''
        if live
          return "<img class='#{img_class}' data-proxy='#{proxy}' src='#{uri}' alt='Camera appears to be offline' width='100%' height='auto'>".html_safe
        else
          return "<img class='#{img_class}' data-proxy='#{proxy}' src='#{uri}' >".html_safe
        end
      end
    end
    if live
      "<img class='live' src='#{proxy}' alt='Camera appears to be offline' width='100%' height='auto'>".html_safe
    else
      "<img class='live' src='#{proxy}' onerror=\"this.style.display='none'\" alt=''>".html_safe
    end
  end

end
