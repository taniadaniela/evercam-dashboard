module ApplicationHelper
  #noinspection RubyArgCount
  def API_call(url, method, body={}, params={})
    unless current_user.nil?
      if method == :post
        params.merge!({:api_id => current_user.api_id,
                       :api_key => current_user.api_key})
      else
        params.merge!({:api_id => current_user.api_id,
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
      connecttimeout: TIMEOUT
    )
    request.run
    request.response
  end
end
