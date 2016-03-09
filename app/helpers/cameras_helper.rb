module CamerasHelper
  def preview(camera, _refresh = false)
    thumbnail = thumbnail_url(camera)
    image_tag(thumbnail, class: "camera-thumbnail", alt: "camera-thumbnail", camera: "camera-thumbnail", "data-proxy": thumbnail)
  end

  def thumbnail_url(camera)
    if camera['is_public'] && camera['discoverable']
      "#{EVERCAM_MEDIA_API}cameras/#{camera['id']}/thumbnail"
    else
      "#{EVERCAM_MEDIA_API}cameras/#{camera['id']}/thumbnail?api_id=#{current_user.api_id}&api_key=#{current_user.api_key}"
    end
  end
end
