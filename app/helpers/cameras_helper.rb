module CamerasHelper
  def preview(camera)
    res = API_call("cameras/#{camera['id']}/snapshots/latest.json", :get, {}, {:with_data => true})
    proxy = "#{EVERCAM_API}cameras/#{camera['id']}/snapshot.jpg?api_id=#{current_user.api_id}&api_key=#{current_user.api_key}"
    if res.success?
      snapshots = JSON.parse(res.body)['snapshots']
      unless snapshots.empty?
        uri = URI::Data.new(snapshots[0]['data'])
        return "<img class='snap' data-proxy='#{proxy}' src='#{uri}' onerror=\"this.style.display='none'\" alt=''>".html_safe
      end
    end
    "<img class='live' src='#{proxy}' onerror=\"this.style.display='none'\" alt=''>".html_safe
  end
end
