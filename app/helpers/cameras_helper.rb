module CamerasHelper
  def preview(camera, refresh=false)
    thumbnail_url = "#{EVERCAM_MEDIA_API}cameras/#{camera['id']}/thumbnail?api_id=#{current_user.api_id}&api_key=#{current_user.api_key}"
    image_tag(thumbnail_url, alt: "camera thumbnail")
  end
end
