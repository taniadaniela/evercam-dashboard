class Admin::DashVendorModelController < AdminController

  def index
    @total_vendors = DashVendor.all.count
    @total_cameras = DashCamera.all.count
  end

  def load_vendor_model
    condition = "lower(vendor_models.name) like lower('%#{params[:vendor_model]}%') OR
                 lower(vendors.name) like lower('%#{params[:vendor]}%') "
    dash_vendors_models = DashVendorModel.joins(:vendor).where(condition)
    total_records = dash_vendors_models.count
    display_length = params[:length].to_i
    display_length = display_length < 0 ? total_records : display_length
    display_start = params[:start].to_i
    table_draw = params[:draw].to_i

    index_end = display_start + display_length
    index_end = index_end > total_records ? total_records - 1 : index_end
    records = {:data => [], :draw => table_draw, :recordsTotal => total_records, :recordsFiltered => total_records}

    (display_start..index_end).each do |index|
      records[:data][records[:data].count] = [
        dash_vendors_models[index].exid,
        dash_vendors_models[index].vendor.name,
        dash_vendors_models[index].name,
        dash_vendors_models[index].config['snapshots'] && dash_vendors_models[index].config['snapshots']['jpg'] ? dash_vendors_models[index].config['snapshots']['jpg'] : '',
        dash_vendors_models[index].config['snapshots'] && dash_vendors_models[index].config['snapshots']['h264'] ? dash_vendors_models[index].config['snapshots']['h264'] : '',
        dash_vendors_models[index].config['snapshots'] && dash_vendors_models[index].config['snapshots']['mjpg'] ? dash_vendors_models[index].config['snapshots']['mjpg'] : '',
        dash_vendors_models[index].config['snapshots'] && dash_vendors_models[index].config['snapshots']['mpeg4'] ? dash_vendors_models[index].config['snapshots']['mpeg4'] : '',
        dash_vendors_models[index].config['snapshots'] && dash_vendors_models[index].config['snapshots']['mobile'] ? dash_vendors_models[index].config['snapshots']['mobile'] : '',
        dash_vendors_models[index].config['snapshots'] && dash_vendors_models[index].config['snapshots']['lowres'] ? dash_vendors_models[index].config['snapshots']['lowres'] : '',
        dash_vendors_models[index].config['auth'] && dash_vendors_models[index].config['auth']['basic'] ? dash_vendors_models[index].config['auth']['basic']['username'] : '',
      dash_vendors_models[index].config['auth'] && dash_vendors_models[index].config['auth']['basic'] ? dash_vendors_models[index].config['auth']['basic']['password'] : '']
    end

    render json: records
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