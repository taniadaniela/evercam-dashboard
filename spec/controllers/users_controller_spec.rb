require 'spec_helper'

describe UsersController do

  let!(:user) {create(:active_user)}
  let(:params) {
    {user: {
        forename: user.forename,
        lastname: user.lastname,
        username: user.username,
        email: user.email,
        password: 'password'
        },
      country: 'ie'}
  }
  let(:patch_params) {
    {id: user.username,
     'user-forename' => 'Aaaddd',
     'user-lastname' => 'Bbbeeee',
     email: "#{user.username}2@evercam.io",
     password: 'asdf',
     country: 'pl'}
  }
  let(:new_user_params) {
    id = SecureRandom.hex(8)
    {user: {forename: 'Joe',
            lastname: 'Bloggs',
            username: id,
            email: "#{id}@nowhere.com",
            password: 'password'},
      country: 'ie'}
  }

  describe 'GET #new' do
    it "renders the :new" do
      get :new
      expect(response.status).to eq(200)
      expect(response).to render_template :new
    end
  end

  describe 'POST #create with wrong params' do
    it "renders the :new" do
      post :create, {}
      expect(response.status).to eq(200)
      expect(response).to render_template :new
    end
  end

  describe 'POST #create with correct params' do
    it "signs in and redirects to cameras index" do
      stub_request(:post, "https://api.evercam.io/v1/users").to_return(:status => 200, :body => "", :headers => {})

      post :create, new_user_params
      expect(response.status).to eq(302)
      expect(response).to redirect_to "/"
    end
  end

  describe 'GET #settings' do
    it "redirects to signup" do
      get :settings, {id: 'tester'}
      expect(response).to redirect_to('/signin')
    end
  end

  describe 'POST #settings' do
    it "redirects to signup" do
      post :settings_update, {id: 'tester'}
      expect(response).to redirect_to('/signin')
    end
  end

  context 'with auth' do
    describe 'GET #settings' do
      it "renders the :settings" do
        stub_request(:patch, "https://api.evercam.io/v1/users/#{user.username}?api_id=#{user.api_id}&api_key=#{user.api_key}").
          with(:body => "country=&email=&forename=&lastname=").
          to_return(:status => 200, :body => "", :headers => {})

        session['user'] = user.email
        get :settings, {id: user.username}
        expect(response.status).to eq(200)
        expect(response).to render_template :settings
      end
    end

    describe 'POST #settings_update with wrong params' do
      it "fails and renders user settings" do
        stub_request(:patch, "https://api.evercam.io/v1/users/#{user.username}?api_id=#{user.api_id}&api_key=#{user.api_key}").
          with(:body => "country=&email=&forename=&lastname=").
          to_return(status: 400, headers: {},
                    body: "{\"message\":[\"forename can't be blank\",\"lastname can't be blank\",\"country can't be blank\",\"email can't be blank\",\"country is invalid\"]}")

        session['user'] = user.email
        post :settings_update, {id: user.username}
        expect(response.status).to eq(200)
        expect(response).to render_template :settings
        expect(flash[:message]).to eq(["forename can't be blank", "lastname can't be blank",
                                       "country can't be blank", "email can't be blank",
                                       "country is invalid"])
      end
    end

    describe 'POST #settings_update with correct params, but for different user' do
      it "signs out and redirects to sign in" do
        session['user'] = params[:user][:email]
        post :settings_update, {id: 'tester'}
        expect(response.status).to eq(302)
        expect(response).to redirect_to '/signin'
      end
    end

    describe 'POST #settings_update with correct params' do
      it "updates and renders user settings" do
        stub_request(:patch, "https://api.evercam.io/v1/users/#{user.username}?api_id=#{user.api_id}&api_key=#{user.api_key}").
          to_return(:status => 200, :body => "", :headers => {})

        session['user'] = params[:user][:email]
        post :settings_update, patch_params
        expect(response.status).to eq(200)
        expect(response).to render_template :settings
        expect(flash[:message]).to eq('Settings updated successfully')
      end
    end
  end

end
