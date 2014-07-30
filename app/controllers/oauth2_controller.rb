class Oauth2Controller < ApplicationController
  before_filter :authenticate_user!, :only => [:feedback, :authorize]
  include SessionsHelper
  include ApplicationHelper
  include Oauth2Helper

  # The fall back error page when a redirect is not possible.
  def error

  end

  # This method gets hit when the user either approves or declines a rights
  # request.
  def feedback
    redirect_uri = '/oauth2/error'
    Rails.logger.debug "POST /oauth2/feedback\nPARAMETERS: #{params}"
    begin
      raise ACCESS_DENIED if !params[:action_type]

      settings = session[:oauth]
      raise ACCESS_DENIED if settings.nil?
      session[:oauth] = nil
      redirect_uri  = settings[:redirect_uri]
      response_type = settings[:response_type]
      token         = AccessToken[settings[:access_token_id]]
      raise ACCESS_DENIED if token.nil?
      if params[:action_type].strip.downcase == 'approve'
        client = Client[api_id: settings[:client_id]]
        scopes = parse_scope(settings[:scope])
        grant_missing_rights(client, token, current_user, scopes)
        if redirect_uri
          redirect_to generate_response_uri(redirect_uri,
                                         token,
                                         response_type,
                                         settings[:state]).to_s
        else
          render :json => generate_response(token, response_type, settings[:state]), :callback => params['callback']
        end
      else
        raise ACCESS_DENIED
      end
    rescue => error
      Rails.logger.error "#{error}\n" + error.backtrace.join("\n")
      redirect_to generate_error_uri(redirect_uri, {error: error}).to_s
    end
  end

  # Step 1 of the authorization process for both the implicit and explicit
  # authorization flows.
  def authorize
    redirect_uri    = nil
    session[:oauth] = nil
    Rails.logger.debug "GET /oauth2/authorize\nParameters: #{params}"
    begin
      response_type = params[:response_type]
      raise INVALID_REDIRECT_URI if response_type == 'code' && !params[:redirect_uri]
      redirect_uri = params[:redirect_uri]

      raise UNSUPPORTED_RESPONSE_TYPE if !valid_response_type?(params[:response_type])
      raise INVALID_REQUEST if !params[:client_id]

      @client = Client.where(api_id: params[:client_id]).first
      raise ACCESS_DENIED if @client.nil?
      raise INVALID_REDIRECT_URI if redirect_uri && !valid_redirect_uri?(@client, redirect_uri)

      scopes = parse_scope(params[:scope])

      expiration = Time.now + (response_type == "token" ? 315569000 : 3600)
      token      = AccessToken.create(refresh:    SecureRandom.base64(24),
                                      client:     @client,
                                      grantor:    current_user,
                                      expires_at: expiration)

      if !has_all_rights?(@client, token, current_user, scopes)
        # Rights confirmation needed from user.
        Rails.logger.debug "Rights grant confirmation needed, displaying page to user."
        session[:oauth] = {access_token_id: token.id,
                           client_id:       @client.api_id,
                           response_type:   response_type,
                           scope:           params[:scope],
                           redirect_uri:    redirect_uri,
                           state:           params[:state]}
        @permissions = enumerate_rights(scopes)
      else
        # Request has all the rights needed, drop straight through.
        Rails.logger.debug "No rights grant confirmation needed, responding with result."
        if redirect_uri
          redirect_to generate_response_uri(redirect_uri, token,
                                         response_type, params[:state]).to_s
        else
          render :json => generate_response(token, response_type, params[:state]).to_json, :callback => params['callback']
        end
      end
    rescue => error
      Rails.logger.error "#{error}\n" + error.backtrace.join("\n")
      redirect_uri = '/oauth2/error' if redirect_uri.nil?
      if "#{error}" != INVALID_REDIRECT_URI
        redirect_to generate_error_uri(redirect_uri, {error: "#{error}"}).to_s
      else
        redirect_to generate_error_uri('/oauth2/error', {error: "#{error}"}).to_s
      end
    end
  end

  # Step 2 of the authorization process for the explicit flow only.
  def post_authorize
    session[:oauth] = nil
    redirect_uri    = nil
    Rails.logger.debug "POST /oauth2/authorize\nPARAMETERS: #{params}"
    begin
      redirect_uri = params[:redirect_uri]
      grant_type   = params[:grant_type]

      raise INVALID_REQUEST if !['authorization_code', 'refresh_token'].include?(grant_type)
      raise INVALID_REQUEST if grant_type == "authorization_code" && !params[:code]
      raise INVALID_REQUEST if grant_type == "refresh_token" && !params[:refresh_token]
      raise INVALID_REQUEST if grant_type == "authorization_code" && !params[:client_id]
      raise INVALID_REQUEST if !params[:client_secret]

      client = nil
      token  = nil
      if grant_type == 'refresh_token'
        token = AccessToken.where(refresh: params[:refresh_token]).first
        raise UNAUTHORIZED_CLIENT if token.nil?
        raise INVALID_REQUEST if token.client_id.nil?
        client = token.client
      else
        client = Client.where(api_id: params[:client_id]).first
      end
      raise UNAUTHORIZED_CLIENT if client.nil?
      raise INVALID_REDIRECT_URI if redirect_uri.nil? || !valid_redirect_uri?(client, redirect_uri)

      Rails.logger.debug "Making call to 3Scale to authorize client."
      provider_key = Evercam::Config[:threescale][:provider_key]
      three_scale  = ::ThreeScale::Client.new(:provider_key => provider_key)
      response     = three_scale.authrep(app_id: client.api_id,
                                         app_key: params[:client_secret])
      Rails.logger.debug "3Scale request successful: #{response.success?}"
      raise UNAUTHORIZED_CLIENT if !response.success?

      code = params[(grant_type == 'authorization_code') ? :code : :refresh_token]
      token = AccessToken.where(refresh: code).first if token.nil?
      raise ACCESS_DENIED if token.nil? || token.is_revoked?

      render :json => generate_response(token, 'authorization_code', params[:state]), :callback => params['callback']
    rescue => error
      Rails.logger.error "#{error}\n" + error.backtrace.join("\n")
      redirect_uri = '/oauth2/error' if redirect_uri.nil?
      if "#{error}" != INVALID_REDIRECT_URI
        redirect_to generate_error_uri(redirect_uri, {error: "#{error}"}).to_s
      else
        redirect_to generate_error_uri('/oauth2/error', {error: "#{error}"}).to_s
      end
    end
  end

  # Fetch details for an allocated token.
  def tokeninfo
    output = {error: INVALID_REQUEST}
    code   = 400
    Rails.logger.debug "GET /oauth2/tokeninfo\nPARAMETERS: #{params}"
    if params[:access_token]
      token = AccessToken.where(request: params[:access_token]).first
      if token && !token.client_id.nil?
        output = {access_token: token.request,
                  audience:     token.client.api_id,
                  expires_in:   token.expires_in}
        output[:userid] = token.grantor.username if token.grantor_id
        code = 200
      end
    end
    render :json => output, :callback => params['callback'], :status => code
  end

  # Revoke an existing client token.
  def revoke
    output = {error: INVALID_REQUEST}
    code   = 400
    Rails.logger.debug "GET /oauth2/revoke\nPARAMETERS: #{params}"
    if params[:access_token]
      token = AccessToken.where(request: params[:access_token]).first
      if token && !token.client_id.nil?
        token.update(is_revoked: true) if !token.is_revoked?
        output = {}
        code   = 200
      end
    end
    render :json => output, :callback => params['callback'], :status => code
  end
end
