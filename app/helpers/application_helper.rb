module ApplicationHelper
  include SessionsHelper

  def vendors
    Vendor.order(:name).all
  end

  def models(vendor_id)
    VendorModel
      .select(:exid, :name, :jpg_url, :mjpg_url, :h264_url, :vendor_id, :config)
      .where(vendor_id: vendor_id)
      .order(Sequel.lit("case when name = 'Default' then 0 else 1 end, name"))
      .all
  end

  def timezones
    Timezone::Zone.names.to_a
  end

  def is_active?(link_path)
    current_page?(link_path) ? "active" : ""
  end
end
