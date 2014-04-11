module ApplicationHelper
  #noinspection RubyArgCount
  def API_call(url, method, body={}, params={})
    unless current_user.nil?
      if method == :post
        body.merge!({:api_id => current_user.api_id,
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
                       "   URI:        http://localhost:9292/v1#{url}"

    request = Typhoeus::Request.new(
      #EVERCAM_API + url,
      "http://localhost:9292/v1" + url,
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
