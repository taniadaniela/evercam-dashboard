class Admin::DashUsersController < AdminController

  def index
    @dash_users = DashUser.all.includes(:dash_country)
  end

  def show
    @dash_user = DashUser.find(params[:id])
  end

end
