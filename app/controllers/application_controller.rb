class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :authenticate_user!, :set_cache_buster

  def authenticate_user!
    if current_user.nil?
      user = nil
      original_url = request.original_url
      if params.has_key?(:api_id) and params.has_key?(:api_key)
        user = User.where(api_id: params[:api_id], api_key: params[:api_key]).first
        #TODO: replace this with a more robust solution
        original_url = original_url.gsub(/api_id=[a-zA-Z0-9]+&/, '').gsub(/api_key=[a-zA-Z0-9]+&?/, '')
      end

      if user.nil?
        session[:redirect_url] = original_url
        redirect_to signin_path
      else
        sign_in user
        redirect_to original_url
      end
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

  def load_user_cameras(shared, thumbnail)
    api = get_evercam_api
    begin
      api.get_user_cameras(current_user.username, shared, thumbnail) if @cameras.blank?
    rescue => error
      Rails.logger.error "Exception caught fetching user cameras.\nCause: #{error}"
    end
  end
end
