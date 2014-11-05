class Admin::DashVendorModelController < AdminController

  def index
    @dash_vendors_models = DashVendorModel.all.includes(:vendor)
  end

end