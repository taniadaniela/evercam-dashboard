module ApplicationHelper
  def API_call(url, method, body={}, params={})
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
