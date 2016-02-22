module CamerasHelper
  def preview(camera, _refresh = false)
    image_tag(thumbnail_url(camera), alt: "camera thumbnail")
  end

  def thumbnail_url(camera)
    "#{EVERCAM_MEDIA_API}cameras/#{camera['id']}/thumbnail?api_id=#{current_user.api_id}&api_key=#{current_user.api_key}"
  end
end
