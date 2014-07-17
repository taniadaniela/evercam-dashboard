class Admin::DashCamerasController < AdminController

  def index
    @dash_cameras = DashCamera.all
  end

end
