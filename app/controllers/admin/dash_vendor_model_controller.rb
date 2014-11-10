class Admin::DashVendorModelController < AdminController

  def index
    @dash_vendors_models = DashVendorModel.all.includes(:vendor)
    @total_vendors = DashVendor.all.count
    @total_cameras = DashCamera.all.count
  end

  def show
    @dash_vendor_model = DashVendorModel.includes(:vendor).find(params[:id])
    @total_cameras = DashCamera.where(model_id: params[:id])
  end

  def update
    begin
      @vendor_model = DashVendorModel.find(params[:id])
      @vendor_model.update_attributes(name: params['name'], jpg_url: params['jpg_url'])

      @vendor = DashVendor.find(params['vendor_id'])
      @vendor.update_attribute(:name, params['vendor_name'])

      flash[:message] = 'Vendor Model updated successfully'
      redirect_to "/admin/models/#{params['id']}"
    rescue => error
      env["airbrake.error_id"] = notify_airbrake(error)
      Rails.logger.error "Exception caught updating vendor model details.\nCause: #{error}\n" +
                             error.backtrace.join("\n")
      flash[:message] = "An error occurred updating the vendor model details. "\
                        "Please try again and, if this problem persists, contact "\
                        "support."
      redirect_to "/admin/models/#{params['id']}"
    end
  end

end