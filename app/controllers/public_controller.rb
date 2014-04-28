class PublicController < ApplicationController
  include SessionsHelper
  include ApplicationHelper

  def index
    @cameras = Camera.where(is_public: true).all.find_all { |c| !c.external_jpg_url.blank?}
  end

  def single
    puts params
    @cameras = Camera.where(exid: params[:id]).first
  end

end