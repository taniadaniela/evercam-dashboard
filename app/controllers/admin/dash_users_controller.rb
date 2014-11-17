class Admin::DashUsersController < AdminController

  def index
    @dash_users = DashUser.all.includes(:dash_country, :dash_cameras)
  end

  def show
    @dash_user = DashUser.find(params[:id])
    @countries = Country.all
  end

  def update
    begin
      @dash_user = DashUser.find(params[:id])
      @dash_user.update_attributes(firstname: params['firstname'], lastname: params['lastname'],
                               email: params['email'], country_id: params['country_id'],
                               is_admin: params['is_admin'])

      flash[:message] = "User details updated successfully"
      redirect_to "/admin/users/#{params['id']}"
    rescue => error
      env["airbrake.error_id"] = notify_airbrake(error)
      Rails.logger.error "Exception caught updating User details.\nCause: #{error}\n" +
                             error.backtrace.join("\n")
      if(error.message.index("ux_users_email"))
        flash[:message] = "The email address specified is already registered for an Evercam account."
      else
        flash[:message] = "An error occurred updating User details. "\
                          "Please try again and, if this problem persists, contact support."
      end
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
