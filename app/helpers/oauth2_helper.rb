module Oauth2Helper
  # Recognised response types.
  VALID_RESPONSE_TYPES = ['code', 'token']

  # Error definitions.
  ACCESS_DENIED             = "access_denied"
  INVALID_REDIRECT_URI      = "invalid_redirect_uri"
  INVALID_REQUEST           = "invalid_request"
  INVALID_SCOPE             = "invalid_scope"
  SERVER_ERROR              = "server_error"
  TEMPORARILY_UNAVAILABLE   = "temporarily_unavailable"
  UNAUTHORIZED_CLIENT       = "unauthorized_client"
  UNSUPPORTED_RESPONSE_TYPE = "unsupported_response_type"

  def valid_response_type?(type)
    VALID_RESPONSE_TYPES.include?(type.to_s.strip.downcase)
  end

  # Used to test whether the specified redirect URI is valid.
  def valid_redirect_uri?(client, uri)
    compare = URI.parse(uri)
    client && client.callback_uris && client.callback_uris.find do |entry|
      if entry[0,4] == "http"
        entry == uri
      else
        entry.index(":").nil? ? (entry == compare.host) : (entry == ("#{compare.host}:#{compare.port}"))
      end
    end.nil? == false
  end

  # Take a single scope definition and translate it into a string.
  def interpret_scope(scope)
    resource, right, extent = scope.split(":")
    output = {right: right}
    if resource == 'cameras'
      output[:target] = "all of your existing cameras"
    elsif resource == "camera"
      output[:target] = "'#{extent}' camera"
    elsif resource == 'snapshots'
      output[:target] = "all of your existing snapshots"
    elsif resource == "user"
      if right == "view"
        output[:target] = "your account details"
      else
        output[:target] = "your account"
      end
    else
      raise INVALID_SCOPE
    end
    output
  end

  def parse_scope(scope)
    if scope
      scope.strip.include?(' ') ? scope.strip.split(' ') : [scope.strip]
    else
      []
    end
  end

  # Translate the scope request into a list of scope strings.
  def enumerate_rights(scopes)
    scopes.inject([]) {|list, scope| list << interpret_scope(scope); list}
  end

  # Used to check whether the request requires the addition of access rights.
  def has_all_rights?(client, token, user, scopes)
    missing_rights(client, token, user, scopes).size == 0
  end

  # Fetches a list of rights not currently held by a client.
  def missing_rights(client, token, user, scopes)
    rights_list = []
    scopes.each do |scope|
      type, right, target = scope.split(":")
      if !AccessRight::ALL_SCOPES.include?(type)
        rights_list.concat(resources_for_scope(scope, user).inject([]) do |list, resource|
          list << scope if !AccessRightSet.for(resource, client).allow?(right)
          list
        end)
      else
        rights = AccountRightSet.new(user, client, type)
        rights_list << scope if !rights.allow?(right)
      end
    end
    rights_list
  end

  # This method grants a client all rights that they currently don't have to
  # meet a list of scopes.
  def grant_missing_rights(client, token, user, scopes)
    missing_rights(client, token, user, scopes).each do |scope|
      type, right, target = scope.split(":")
      if AccessRight::ALL_SCOPES.include?(type)
        # Grant an account level right.
        AccountRightSet.new(user, client, type).grant(right)
      else
        # Grant individual resource rights.
        resources_for_scope(scope, user).each do |resource|
          AccessRightSet.for(resource, client).grant(right)
        end
      end
    end
  end

  # Fetches the list of resources that are associated with a scope.
  def resources_for_scope(scope, user)
    resources = []
    resource, right, target = scope.split(":")
    if resource == "cameras"
      Camera.where(owner: user).each do |camera|
        resources << camera if AccessRightSet.for(camera, user).allow?(right)
      end
    elsif resource == "camera"
      camera = Camera.where(exid: target).first
      if !camera.nil?
        resources << camera if AccessRightSet.for(camera, user).allow?(right)
      end
    elsif resource == "snapshots"
      camera_ids = Camera.where(owner: user).inject([]) {|list, entry| list << entry.id; list}
      Snapshot.where(camera_id: camera_ids).each do |snapshot|
        resources << snapshot if AccessRightSet.for(snapshot, user).allow?(right)
      end
    elsif resource != "user"
      raise INVALID_SCOPE
    end
    resources
  end

  # Creates a Hash of response parameters for a redirect.
  def generate_response(token, response_type, state=nil)
    details = nil
    if response_type == 'code'
      details = {code:  token.refresh_code}
    elsif response_type == 'authorization_code'
      details  = {access_token:  token.request,
                  refresh_token: token.refresh_code,
                  token_type:    :bearer,
                  expires_in:    token.expires_in}
    else
      details  = {access_token: token.request,
                  token_type:   :bearer,
                  expires_in:   token.expires_in}
    end
    details[:state] = state if state
    details
  end

  # Generates a URI for responding to a rights request.
  def generate_response_uri(uri, token, response_type, state=nil)
    details = generate_response(token, response_type, state)
    if ['code', 'authorization_code'].include?(response_type)
      URI.join(uri, "?#{URI.encode_www_form(details)}")
    else
      URI.join(uri, "##{URI.encode_www_form(details)}")
    end
  end

  # Generates a URI for redirecting to an error.
  def generate_error_uri(uri, error)
    uri = URI.parse(uri)
    uri.query = URI.encode_www_form(error)
    uri
  end

end
