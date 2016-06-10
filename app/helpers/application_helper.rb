module ApplicationHelper
  include SessionsHelper

  def avatar_url(email)
    default_url = "https://evercam.io/img/evercamconnect.png"
    gravatar_id = Digest::MD5.hexdigest(email.downcase)
    "//gravatar.com/avatar/#{gravatar_id}?d=#{default_url}"
  end

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
    current_page?(link_path) ? 'active' : ''
  end

  def get_evercam_api
    configuration = Rails.application.config
    parameters = {logger: Rails.logger}
    if current_user
      parameters = parameters.merge(
        api_id: current_user.api_id,
        api_key: current_user.api_key
      )
    end
    settings = {}
    begin
      settings = (configuration.evercam_api || {})
    rescue => _error
      # Deliberately ignored.
    end
    parameters = parameters.merge(settings) if !settings.empty?
    Evercam::API.new(parameters)
  end

  def format_time stamp
    t = Time.at(stamp)
    t.to_formatted_s(:long)
  end

  # Bug here is rounding amounts, and not showing the cents correctly
  def cents_to_currency amount
    amount / 100
    # number_to_currency(amount / 100, :precision => 2)
  end
end
