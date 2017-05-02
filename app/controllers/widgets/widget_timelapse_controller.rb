class Widgets::WidgetTimelapseController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:timelapse_js]
  include SessionsHelper
  include ApplicationHelper

  def timelapse_js
    respond_to do |format|
      format.js { render :file => "widgets/widget_timelapse/timelapse_widget.js.erb", :mime_type => Mime::Type.lookup('text/javascript')}
    end
  end
end