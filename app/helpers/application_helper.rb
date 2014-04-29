module ApplicationHelper
  include SessionsHelper
  #noinspection RubyArgCount
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
    Rails.logger.debug "API Response:\n#{request.response.body}"
    request.response
  end
end
