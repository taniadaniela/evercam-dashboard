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
    @cameras = Rails.cache.fetch("#{current_user.username}/cameras")
    @shares  = Rails.cache.fetch("#{current_user.username}/shares")
    if @cameras.nil? or @shares.nil?
      @cameras = []
      @shares = []
    else
      return
    end
    api      = get_evercam_api
    begin
      @cameras = api.get_user_cameras(current_user.username, true, true)
    rescue => error
      Rails.logger.error "Exception caught fetching user cameras.\nCause: #{error}"
    end
    @cameras.each {|camera| @shares << camera unless camera['owned'] }
    @cameras = @cameras - @shares if @shares.length > 0
    Rails.cache.write("#{current_user.username}/cameras", @cameras, expires_in: 5.minutes)
    Rails.cache.write("#{current_user.username}/shares", @shares, expires_in: 5.minutes)
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
