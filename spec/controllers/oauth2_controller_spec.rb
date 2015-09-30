require 'spec_helper'

describe Oauth2Controller do

  let(:camera0) { create(:camera, is_public: false) }

  let(:user0) { camera0.owner }

  let(:client0) { create(:client, api_id: 'client0', callback_uris: nil) }

  let(:valid) do
    {
      response_type: 'token',
      client_id: client0.api_id,
      redirect_uri: client0.default_callback_uri,
      scope: "camera:view:#{camera0.exid}"
    }
  end

  let(:get_parameters) do
    {client_id: 'client0',
     redirect_uri: 'https://www.google.com',
     response_type: 'code',
     scope: 'cameras:view'}
  end

  let(:post_parameters) do
    {client_id: 'client0',
     client_secret: 'abcdefgh',
     redirect_uri: 'https://www.google.com',
     grant_type: 'authorization_code'}
  end

  describe 'GET /oauth2/authorize' do
    context 'when a redirect_uri is not specified' do
      it 'redirects with a /oauth2/error' do
        session['user'] = user0.email
        get_parameters.delete(:redirect_uri)
        get(:authorize, get_parameters, {})

        expect(response.status).to eq(302)
        uri    = URI.parse(response.location)
        expect(uri.path).to eq('/oauth2/error')
        expect(uri.query).to eq('error=invalid_redirect_uri')
      end
    end

    context 'when a response type is not specified' do
      it 'hits the redirect URI with an error' do
        session['user'] = user0.email
        get_parameters.delete(:response_type)
        get(:authorize, get_parameters, {})

        expect(response.status).to eq(302)
        uri    = URI.parse(response.location)
        expect(uri.host).to eq('www.google.com')
        expect(uri.query).to eq('error=unsupported_response_type')
      end
    end

    context 'when a client id is not specified' do
      it 'hits the redirect URI with an error' do
        session['user'] = user0.email
        get_parameters.delete(:client_id)
        get(:authorize, get_parameters, {})

        expect(response.status).to eq(302)
        uri    = URI.parse(response.location)
        expect(uri.host).to eq('www.google.com')
        expect(uri.query).to eq('error=invalid_request')
      end
    end

    context 'when an invalid client id is specified' do
      it 'hits the redirect URI with an error' do
        session['user'] = user0.email
        get_parameters[:client_id] = 'xxxx'
        get(:authorize, get_parameters, {})

        expect(response.status).to eq(302)
        uri    = URI.parse(response.location)
        expect(uri.host).to eq('www.google.com')
        expect(uri.query).to eq('error=access_denied')
      end
    end

    context 'when an invalid redirect URL for the client is specified'do
      let(:client1) {
        create(:client, callback_uris: ["https://www.yahoo.com"])
      }

      it 'redirects with a /oauth2/error' do
        session['user'] = user0.email
        get_parameters[:client_id] = client1.api_id
        get(:authorize, get_parameters, {})

        expect(response.status).to eq(302)
        uri    = URI.parse(response.location)
        expect(uri.path).to eq('/oauth2/error')
        expect(uri.query).to eq('error=invalid_redirect_uri')
      end
    end

    context "user session tests" do
      let(:client2) { create(:client, callback_uris: ["https://www.google.com"]).save }

      context 'when not logged in' do
        it 'redirects to the log in URL' do
          get_parameters[:client_id] = client2.api_id
          get(:authorize, get_parameters)

          expect(response.status).to eq(302)
          uri    = URI.parse(response.location)
          expect(uri.path).to eq(signin_path)
        end
      end

      context "when logged in" do
        context "and it is given all valid parameters" do
          it 'returns success' do
            session['user'] = user0.email
            get_parameters[:client_id] = client2.api_id
            get(:authorize, get_parameters)

            expect(response.status).to eq(200)
          end
        end

        context "and it is given an invalid scope" do
          it 'returns an error' do
            session['user'] = user0.email
            get_parameters[:scope] = "blah:ningy:all"
            get(:authorize, get_parameters)

            expect(response.status).to eq(302)
            uri    = URI.parse(response.location)
            expect(uri.host).to eq('www.google.com')
          end
        end
      end
    end

    context 'when logged in and with all required rights already granted' do
      let(:client3) { create(:client, callback_uris: ["https://www.google.com"]).save }

      before(:each) do
        token = create(:access_token, client: client3, refresh: "rc001")
        AccessRightSet.for(camera0, client3).grant(AccessRight::VIEW)
        token.save
      end

      context 'and a valid code request is made' do
        it 'hits the redirect URI' do
          get_parameters[:client_id] = client3.api_id
          get_parameters[:scope] = "camera:view:#{camera0.exid}"
          session['user'] = user0.email
          get(:authorize, get_parameters)

          expect(response.status).to eq(302)
          uri = URI.parse(response.location)
          expect(uri.host).to eq('www.google.com')
          map = URI.decode_www_form(uri.query).inject({}) {|t,a| t[a[0]] = a[1]; t}
          expect(map.include?("code")).to eq(true)
        end
      end

      context 'and a valid code request without a scope is made' do
        it 'hits the redirect URI' do
          get_parameters[:client_id] = client3.api_id
          get_parameters.delete(:scope)
          session['user'] = user0.email
          get(:authorize, get_parameters)

          expect(response.status).to eq(302)
          uri = URI.parse(response.location)
          expect(uri.host).to eq('www.google.com')
          map = URI.decode_www_form(uri.query).inject({}) {|t,a| t[a[0]] = a[1]; t}
          expect(map.include?("code")).to eq(true)
        end
      end

      context 'and a valid token request is made with a redirect URI' do
        it 'hits the redirect URI' do
          get_parameters[:client_id] = client3.api_id
          get_parameters[:scope] = "camera:view:#{camera0.exid}"
          get_parameters[:response_type] = 'token'
          session['user'] = user0.email
          get(:authorize, get_parameters)

          expect(response.status).to eq(302)
          uri = URI.parse(response.location)
          expect(uri.host).to eq('www.google.com')
        end
      end

      context 'and a valid token request is made without a redirect URI' do
        it 'hits the redirect URI' do
          get_parameters[:client_id] = client3.api_id
          get_parameters[:scope] = "camera:view:#{camera0.exid}"
          get_parameters[:response_type] = 'token'
          get_parameters.delete(:redirect_uri)
          session['user'] = user0.email
          get(:authorize, get_parameters)

          expect(response.status).to eq(200)
          expect([nil, ''].include?(response.body)).to eq(false)
          map = JSON.parse(response.body)
          expect(map.include?("access_token")).to eq(true)
          expect(map.include?("token_type")).to eq(true)
          expect(map.include?("expires_in")).to eq(true)
          expect(map.include?("refresh_token")).to eq(false)
        end
      end

      context 'and a valid token request is made without a scope' do
        it 'hits the redirect URI' do
          get_parameters[:client_id] = client3.api_id
          get_parameters[:response_type] = 'token'
          get_parameters.delete(:scope)
          session['user'] = user0.email
          get(:authorize, get_parameters)

          expect(response.status).to eq(302)
          uri = URI.parse(response.location)
          expect(uri.host).to eq('www.google.com')
        end
      end

      context 'and a valid token request is made without a scope or redirect URI' do
        it 'hits the redirect URI' do
          get_parameters[:client_id] = client3.api_id
          get_parameters[:response_type] = 'token'
          get_parameters.delete(:scope)
          get_parameters.delete(:redirect_uri)
          session['user'] = user0.email
          get(:authorize, get_parameters)

          expect(response.status).to eq(200)
          expect([nil, ''].include?(response.body)).to eq(false)
          map = JSON.parse(response.body)
          expect(map.include?("access_token")).to eq(true)
          expect(map.include?("token_type")).to eq(true)
          expect(map.include?("expires_in")).to eq(true)
          expect(map.include?("refresh_token")).to eq(false)
        end
      end
    end
  end

  describe 'POST /oauth2/feedback' do
    let(:access_token) { create(:access_token, refresh: SecureRandom.base64(24)) }
    let(:parameters) { {action_type: 'approve'} }
    let(:code_oauth) {{client_id: client0.api_id,
                       response_type: 'code',
                       scope: 'cameras:snapshot:all',
                       redirect_uri: 'https://www.google.com',
                       access_token_id: access_token.id}}
    let(:token_oauth) {{client_id: client0.api_id,
                        response_type: 'token',
                        scope: 'cameras:snapshot:all',
                        redirect_uri: 'https://www.google.com',
                       access_token_id: access_token.id}}

    before(:each) {access_token.save}

    context 'when an action_type parameter is not specified' do
      it "redirects to /oauth2/error" do
        session['user'] = user0.email
        post(:feedback)

        expect(response.status).to eq(302)
        uri = URI.parse(response.location)
        expect(uri.path).to eq('/oauth2/error')
      end
    end

    context 'when there are no deatils stored in the session' do
      it "redirects to /oauth2/error" do
        session['user'] = user0.email
        post(:feedback, parameters)

        expect(response.status).to eq(302)
        uri = URI.parse(response.location)
        expect(uri.path).to eq('/oauth2/error')
      end
    end

    context 'when an action_type other than approve is specified' do
      it "hits the redirect URI with an error" do
        session['user'] = user0.email
        session['oauth'] = code_oauth
        post(:feedback, {action_type: 'decline'})

        expect(response.status).to eq(302)
        uri = URI.parse(response.location)
        expect(uri.host).to eq('www.google.com')
        expect(uri.query).to eq("error=access_denied")
      end
    end

    context 'when the action_type specified is approve' do
      context 'for a response type of code' do
        it "it hits the redirect URI with the right details in the query" do
          session['user'] = user0.email
          session['oauth'] = code_oauth
          post(:feedback, parameters)

          expect(response.status).to eq(302)
          uri = URI.parse(response.location)
          expect(uri.host).to eq('www.google.com')
          map = URI.decode_www_form(uri.query).inject({}) {|t,a| t[a[0]] = a[1]; t}
          expect(map.include?("code")).to eq(true)
        end
      end

      context 'for a response type of token with a redirect URI' do
        it "it hits the redirect URI with the right details in the fragment" do
          session['user'] = user0.email
          session['oauth'] = token_oauth
          post(:feedback, parameters)

          expect(response.status).to eq(302)
          uri = URI.parse(response.location)
          expect(uri.host).to eq('www.google.com')
          map = URI.decode_www_form(uri.fragment).inject({}) {|t,a| t[a[0]] = a[1]; t}
          expect(map.include?("access_token")).to eq(true)
          expect(map.include?("token_type")).to eq(true)
          expect(map.include?("expires_in")).to eq(true)
        end
      end

      context 'for a response type of token without a redirect URI' do
        it "it hits the redirect URI with the right details in the fragment" do
          session['user'] = user0.email
          session['oauth'] = token_oauth
          session['oauth'].delete(:redirect_uri)
          #token_settings["rack.session"][:oauth].delete(:redirect_uri)
          post(:feedback, parameters)

          expect(response.status).to eq(200)
          expect([nil, ''].include?(response.body)).to eq(false)
          map = JSON.parse(response.body)
          expect(map.include?("access_token")).to eq(true)
          expect(map.include?("token_type")).to eq(true)
          expect(map.include?("expires_in")).to eq(true)
          expect(map.include?("refresh_token")).to eq(false)
        end
      end
    end
  end

  describe 'POST /oauth/authorize' do
    context 'for the code grant flow' do
      let(:access_token) { create(:access_token, client: client0, refresh: SecureRandom.base64(24)) }
      let(:parameters) { {redirect_uri:  'http://www.google.com/blah',
                          grant_type:    'authorization_code',
                          code:          access_token.refresh_code,
                          client_id:     'client0',
                          client_secret: 'client0_secret'} }

      context 'when a grant type is not specified' do
        it 'hits the redirect URI with an error' do
          parameters.delete(:grant_type)
          post(:post_authorize, parameters)

          expect(response.status).to eq(302)
          uri = URI.parse(response.location)
          expect(uri.host).to eq('www.google.com')
          expect(uri.query).to eq('error=invalid_request')
        end
      end

      context 'when an invalid grant type is specified' do
        it 'hits the redirect URI with an error' do
          parameters[:grant_type] = 'blah'
          post(:post_authorize, parameters)

          expect(response.status).to eq(302)
          uri = URI.parse(response.location)
          expect(uri.host).to eq('www.google.com')
          expect(uri.query).to eq('error=invalid_request')
        end
      end

      context 'when a code is not specified' do
        it 'hits the redirect URI with an error' do
          parameters.delete(:code)
          post(:post_authorize, parameters)

          expect(response.status).to eq(302)
          uri = URI.parse(response.location)
          expect(uri.host).to eq('www.google.com')
          expect(uri.query).to eq('error=invalid_request')
        end
      end

      context 'when a client_id is not specified' do
        it 'hits the redirect URI with an error' do
          parameters.delete(:client_id)
          post(:post_authorize, parameters)

          expect(response.status).to eq(302)
          uri = URI.parse(response.location)
          expect(uri.host).to eq('www.google.com')
          expect(uri.query).to eq('error=invalid_request')
        end
      end

      context 'when a client_secret is not specified' do
        it 'hits the redirect URI with an error' do
          parameters.delete(:client_secret)
          post(:post_authorize, parameters)

          expect(response.status).to eq(302)
          uri = URI.parse(response.location)
          expect(uri.host).to eq('www.google.com')
          expect(uri.query).to eq('error=invalid_request')
        end
      end

      context 'when the client id specified does not match an existing client' do
        it 'hits the redirect URI with an error' do
          parameters[:client_id] = 'xxxx'
          post(:post_authorize, parameters)

          expect(response.status).to eq(302)
          uri = URI.parse(response.location)
          expect(uri.host).to eq('www.google.com')
          expect(uri.query).to eq('error=unauthorized_client')
        end
      end

      context 'when the URI specified does not match the clients allowed callback URIs' do
        let(:client1) { create(:client, api_id: 'client1', callback_uris: ['https://www.blah.com/redirect']).save }

        it 'redirects to /oauth2/error' do
          parameters[:client_id] = client1.api_id
          post(:post_authorize, parameters)

          expect(response.status).to eq(302)
          uri = URI.parse(response.location)
          expect(uri.path).to eq('/oauth2/error')
          expect(uri.query).to eq('error=invalid_redirect_uri')
        end
      end

      context 'when 3Scale returns a positive response' do
        before(:each) do
          client0.update(callback_uris: ['http://www.google.com/blah'])
        end

        context 'when a redirect URI is included in the request' do
          it 'returns success and includes data in the response body' do
            post(:post_authorize, parameters)

            expect(response.status).to eq(200)
            expect([nil, ''].include?(response.body)).to eq(false)
            map = JSON.parse(response.body)
            expect(map.include?("access_token")).to eq(true)
            expect(map.include?("refresh_token")).to eq(true)
            expect(map.include?("expires_in")).to eq(true)
            expect(map.include?("token_type")).to eq(true)
          end
        end

        context 'when a redirect URI is not included in the request' do
          it 'returns success and includes data in the response body' do
            parameters.delete(:redirect_uri)
            post(:post_authorize, parameters)

            expect(response.status).to eq(302)
            uri = URI.parse(response.location)
            expect(uri.path).to eq('/oauth2/error')
            expect(uri.query).to eq('error=invalid_redirect_uri')
          end
        end

        context 'when an invalid redirect URI is included in the request' do
          it 'returns success and includes data in the response body' do
            parameters[:redirect_uri] = "https://www.nowhere.com/blah"
            post(:post_authorize, parameters)

            expect(response.status).to eq(302)
            uri = URI.parse(response.location)
            expect(uri.path).to eq('/oauth2/error')
            expect(uri.query).to eq('error=invalid_redirect_uri')
          end
        end
      end
    end

    context 'for the refresh token flow' do
      let(:access_token) { create(:access_token, client: client0, refresh: SecureRandom.base64(24)) }
      let(:parameters) { {redirect_uri:  'http://www.google.com/blah',
                          grant_type:    'refresh_token',
                          refresh_token: access_token.refresh_code,
                          client_secret: 'client0_secret'} }

      context 'when a refresh token is not specified' do
        it 'hits the redirect URI with an error' do
          parameters.delete(:refresh_token)
          post(:post_authorize, parameters)

          expect(response.status).to eq(302)
          uri = URI.parse(response.location)
          expect(uri.host).to eq('www.google.com')
          expect(uri.query).to eq('error=invalid_request')
        end
      end

      context 'when a client_secret is not specified' do
        it 'hits the redirect URI with an error' do
          parameters.delete(:client_secret)
          post(:post_authorize, parameters)

          expect(response.status).to eq(302)
          uri = URI.parse(response.location)
          expect(uri.host).to eq('www.google.com')
          expect(uri.query).to eq('error=invalid_request')
        end
      end

      context 'for valid requests' do
        before(:each) do
          client0.update(callback_uris: ['http://www.google.com/blah'])
        end

        context 'when a redirect URI is included in the request' do
          it 'returns success and includes data in the redirect URL' do
            post(:post_authorize, parameters)

            expect(response.status).to eq(200)
            map = response.body.to_json
            expect(map.include?("access_token")).to eq(true)
            expect(map.include?("refresh_token")).to eq(true)
            expect(map.include?("expires_in")).to eq(true)
            expect(map.include?("token_type")).to eq(true)
          end
        end

        context 'when a redirect URI is not included in the request' do
          it 'returns success and includes data in the response body' do
            parameters.delete(:redirect_uri)
            post(:post_authorize, parameters)

            expect(response.status).to eq(302)
            uri = URI.parse(response.location)
            expect(uri.path).to eq('/oauth2/error')
            expect(uri.query).to eq('error=invalid_redirect_uri')
          end
        end
      end
    end
  end

  describe 'GET /oauth2/tokeninfo' do
    let(:access_token1) { create(:access_token, request: 'token0001', refresh: 'token0001', client: client0, grantor: user0) }
    let(:access_token2) { create(:access_token, request: 'token0002', refresh: 'token0002', client: nil, user: user0) }

    context 'when an access token is not specified' do
      it 'returns an error response' do
        get(:tokeninfo)
        expect(response.status).to eq(400)
        expect([nil, ''].include?(response.body)).to eq(false)
        output = JSON.parse(response.body)
        expect(output.include?('error')).to eq(true)
        expect(output['error']).to eq('invalid_request')
      end
    end

    context 'when an invalid access token is specified' do
      it 'returns an error response' do
        get(:tokeninfo, {access_token: 'lalala'})
        expect(response.status).to eq(400)
        expect([nil, ''].include?(response.body)).to eq(false)
        output = JSON.parse(response.body)
        expect(output.include?('error')).to eq(true)
        expect(output['error']).to eq('invalid_request')
      end
    end

    context 'when invoked for a user access token' do
      it 'returns an error response' do
        session['user'] = user0.email
        get(:tokeninfo, {access_token: access_token2.request})
        expect(response.status).to eq(400)
        expect([nil, ''].include?(response.body)).to eq(false)
        output = JSON.parse(response.body)
        expect(output.include?('error')).to eq(true)
        expect(output['error']).to eq('invalid_request')
      end
    end

    context 'when invoked for a valid access token' do
      it 'returns success with appropriate parameters' do
        session['user'] = user0.email
        get(:tokeninfo, {access_token: access_token1.request})
        expect(response.status).to eq(200)
        expect([nil, ''].include?(response.body)).to eq(false)
        output = JSON.parse(response.body)
        expect(output.include?("access_token")).to eq(true)
        expect(output.include?("audience")).to eq(true)
        expect(output.include?("expires_in")).to eq(true)
        expect(output.include?("userid")).to eq(true)
        expect(output["access_token"]).to eq(access_token1.request)
        expect(output["audience"]).to eq(client0.api_id)
        expect(output["userid"]).to eq(user0.username)
      end
    end
  end

  describe 'GET /oauth2/revoke' do
    let(:access_token1) { create(:access_token, request: 'token0001', refresh: 'token0001', client: client0) }
    let(:access_token2) { create(:access_token, request: 'token0002', refresh: 'token0002', client: nil, user: user0) }

    context 'when an access token is not specified' do
      it 'returns an error response' do
        get(:revoke)
        expect(response.status).to eq(400)
        expect([nil, ''].include?(response.body)).to eq(false)
        output = JSON.parse(response.body)
        expect(output.include?('error')).to eq(true)
        expect(output['error']).to eq('invalid_request')
      end
    end

    context 'when an invalid access token is specified' do
      it 'returns an error response' do
        get(:revoke, {access_token: 'lalala'})
        expect(response.status).to eq(400)
        expect([nil, ''].include?(response.body)).to eq(false)
        output = JSON.parse(response.body)
        expect(output.include?('error')).to eq(true)
        expect(output['error']).to eq('invalid_request')
      end
    end

    context 'when invoked for a user access token' do
      it 'returns an error response' do
        get(:revoke, {access_token: access_token2.request})
        expect(response.status).to eq(400)
        expect([nil, ''].include?(response.body)).to eq(false)
        output = JSON.parse(response.body)
        expect(output.include?('error')).to eq(true)
        expect(output['error']).to eq('invalid_request')
      end
    end

    context 'when invoked for valid access token' do
      it 'returns success and marks the token as revoked' do
        get(:revoke, {access_token: access_token1.request})
        expect(response.status).to eq(200)
        expect(access_token1.reload.is_revoked?).to eq(true)
      end
    end
  end
end
