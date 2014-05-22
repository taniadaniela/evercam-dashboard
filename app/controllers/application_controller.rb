class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def authenticate_user!
    if current_user.nil?
      session[:redirect_url] = request.original_url
      redirect_to signin_path
      return
    end
  end

  def owns_data!
    if current_user.username != params[:id]
      sign_out
      redirect_to '/signin'
      return
    end
  end

  def load_cameras_and_shares
    @cameras = []
    @shares  = []
    api      = get_evercam_api
    begin
      @cameras = api.get_user_cameras(current_user.username, true)
    rescue => error
      Rails.logger.error "Exception caught fetching user cameras.\nCause: #{error}"
    end
    @cameras.each {|camera| @shares << camera if !camera['owned']}
    @cameras = @cameras - @shares if @shares.length > 0
  end

  def get_evercam_api
    configuration     = Rails.application.config
    settings          = (configuration.evercam_api || {})
    parameters        = {api_id: current_user.api_id,
                         api_key: current_user.api_key,
                         logger: Rails.logger}
    parameters        = parameters.merge(settings) if !settings.empty?
    Evercam::API.new(parameters)
  end
end
