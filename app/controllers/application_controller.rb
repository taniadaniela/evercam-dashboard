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
    reply  = API_call("users/#{current_user.username}/cameras", :get, include_shared: true)
    if reply.success?
      @cameras =  JSON.parse(reply.body)['cameras']
      @cameras.each do |camera|
        camera['jpg'] = "#{EVERCAM_API}cameras/#{camera['id']}/snapshot.jpg?api_id=#{current_user.api_id}&api_key=#{current_user.api_key}"
        @shares << camera if !camera['owned']
      end
      @cameras = @cameras - @shares if @shares.length > 0
    else
      Rails.logger.warn "Request for user cameras was unsuccessful."
    end
  end
end
