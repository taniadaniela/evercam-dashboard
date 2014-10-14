class Admin::DashboardController < AdminController

  def index
    @dash_users = DashUser.all.includes(:dash_country, :dash_cameras)
    @dash_cameras = DashCamera.all.includes(:dash_user, dash_vendor_model: [:vendor])
    @new_users = @dash_users.where('created_at >= ?', 1.month.ago)
    @new_cameras = @dash_cameras.where('created_at >= ?', 1.month.ago)
  end

  def map
    @dash_cameras = DashCamera.where.not(location: nil)
  end

  def kpi
  end

end
