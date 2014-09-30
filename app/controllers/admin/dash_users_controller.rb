class Admin::DashUsersController < AdminController

  def index
    @dash_users = DashUser.all.includes(:dash_country, :dash_cameras)
  end

  def show
    @dash_user = DashUser.find(params[:id])
  end

  def impersonate
    user = User[params[:id]]
    if user
      sign_out
      sign_in user
      redirect_to root_path
    else
      redirect_to :back
    end
  rescue ActionController::RedirectBackError
    redirect_to admin_path
  end
end
