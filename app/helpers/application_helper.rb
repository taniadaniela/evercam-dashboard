module ApplicationHelper
  include SessionsHelper
  #noinspection RubyArgCount

  def vendors
    @vendors ||= Vendor.order(:name).all
  end

  def models(vendor)
    VendorModel.where(:vendor_id => vendor).order(Sequel.lit("case when name = 'Default' then 0 else 1 end, name")).all
  end

  def is_active?(link_path)
    current_page?(link_path) ? "active" : ""
  end

  def API_call(url, method, body={}, params={})
    unless current_user.nil?
      if method == :get
        params.merge!({:api_id => current_user.api_id,
                       :api_key => current_user.api_key})
      else
        body.merge!({:api_id => current_user.api_id,
                     :api_key => current_user.api_key})

      end
    end

    Rails.logger.debug "API Call:\n"\
                       "   Method:     #{method}\n"\
                       "   Body:       #{body}\n"\
                       "   Parameters: #{params}\n"\
                       "   URI:        #{EVERCAM_API + url}"

    request = Typhoeus::Request.new(
      EVERCAM_API + url,
      method: method,
      body: body,
      params: params,
      timeout: TIMEOUT,
      connecttimeout: TIMEOUT,
      followlocation: true
    )
    request.run
    request.response
  end
end
