class Admin::DashUsersController < AdminController

  def index
    @dash_users = DashUser.all
  end

end
