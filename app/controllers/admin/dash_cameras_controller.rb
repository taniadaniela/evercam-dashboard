class Admin::DashCamerasController < AdminController

  def index
    @dash_cameras = DashCamera.all.includes(:dash_user, dash_vendor_model: [:vendor])
  end

  def show
    @dash_camera = DashCamera.find(params[:id])
  end

end
