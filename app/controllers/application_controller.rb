class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :set_cache_buster

  def authenticate_user!
    if current_user.nil?
      session[:redirect_url] = request.original_url
      redirect_to signin_path
    end
  end

  def owns_data!
    if current_user.username != params[:id]
      sign_out
      redirect_to '/signin'
    end
  end

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def load_user_cameras
    api = get_evercam_api
    begin
      @cameras = api.get_user_cameras(current_user.username, true, true)
    rescue => error
      Rails.logger.error "Exception caught fetching user cameras.\nCause: #{error}"
    end
    nil
  end

  def get_evercam_api
    configuration = Rails.application.config
    parameters    = {logger: Rails.logger}
    if current_user
      parameters = parameters.merge(api_id: current_user.api_id,
                                    api_key: current_user.api_key)
    end
    settings      = {}
    begin
      settings = (configuration.evercam_api || {})
    rescue => error
      # Deliberately ignored.
    end
    parameters    = parameters.merge(settings) if !settings.empty?
    Evercam::API.new(parameters)
  end
end
