module CamerasHelper
  def preview(camera, _refresh = false)
    image_tag(thumbnail_url(camera), class:"camera-thumbnail", alt: camera['id'], camera: "camera-thumbnail")
  end

  def thumbnail_url(camera)
    if camera['is_public']
      "#{EVERCAM_MEDIA_API}cameras/#{camera['id']}/thumbnail"
    else
      "#{EVERCAM_MEDIA_API}cameras/#{camera['id']}/thumbnail?api_id=#{current_user.api_id}&api_key=#{current_user.api_key}"
    end
  end
end
