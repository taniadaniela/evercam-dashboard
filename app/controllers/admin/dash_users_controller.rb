class Admin::DashUsersController < AdminController

  def index
    @dash_users = DashUser.all.includes(:dash_country, :dash_cameras)
  end

  def show
    @dash_user = DashUser.find(params[:id])
  end

  def update
    begin
      @dash_user = DashUser.find(params[:id])
      @dash_user.update_attribute(:is_admin, params['userRightsRadios'])

      flash[:message] = "User rights updated successfully"
      redirect_to "/admin/users/#{params['id']}"
    rescue => error
      env["airbrake.error_id"] = notify_airbrake(error)
      Rails.logger.error "Exception caught updating User Rights.\nCause: #{error}\n" +
                             error.backtrace.join("\n")
      flash[:message] = "An error occurred updating User Rights. "\
                        "Please try again and, if this problem persists, contact "\
                        "support."
      redirect_to "/admin/users/#{params['id']}"
    end
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
