module ApplicationHelper
  def API_call(url, method, body={}, params={})
    unless current_user.nil?
      params.merge!({:api_id => current_user.api_id,
                     :api_key => current_user.api_key})
    end
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
