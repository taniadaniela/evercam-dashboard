module ApplicationHelper
  include SessionsHelper
  #noinspection RubyArgCount

  def vendors
    Vendor.order(:name).all
  end

  def models(vendor)
    VendorModel.where(:vendor_id => vendor).order(Sequel.lit("case when name = 'Default' then 0 else 1 end, name")).all
  end

  def is_active?(link_path)
    current_page?(link_path) ? "active" : ""
  end

  def title(page_title)
    content_for :title, page_title.to_s
  end

end
