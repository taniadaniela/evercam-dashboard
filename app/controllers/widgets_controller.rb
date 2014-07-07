class WidgetsController < ApplicationController
  before_filter :authenticate_user!
  skip_before_action :verify_authenticity_token, only: [:live_view_widget]

  include SessionsHelper
  include ApplicationHelper

  def widgets
    current_user
  end

  def widgets_new
    current_user
    load_cameras_and_shares
    @cameras.delete_if { |c| !c['is_public'] or !c['is_online']}
  end


  def live_view_widget
    respond_to do |format|
      format.js { render :file => "widgets/live.view.widget.js" }
    end
  end

end