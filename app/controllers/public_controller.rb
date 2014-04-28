class PublicController < ApplicationController
  include SessionsHelper
  include ApplicationHelper

  def index
    @cameras = Camera.where(is_public: true).all.find_all { |c| !c.external_jpg_url.blank?}
  end

  def single
    @camera = Camera.where(exid: params[:id]).first
    @camera['jpg'] = "#{EVERCAM_API}cameras/#{@camera.exid}/snapshot.jpg"
  end

end