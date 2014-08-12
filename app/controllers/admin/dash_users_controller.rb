class Admin::DashUsersController < AdminController

  def index
    @dash_users = DashUser.all.includes(:dash_country, :dash_cameras)
  end

  def show
    @dash_user = DashUser.find(params[:id])
  end

end
