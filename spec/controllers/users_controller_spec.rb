require 'spec_helper'

describe UsersController do

  before(:all) do
    id = SecureRandom.uuid
    @params = {
      user: {
        forename:'Aaa',
        lastname:'Bbb',
        username: id,
        email: "#{id}@evercam.io",
        password: '12345'
        },
      country: 'ie'
    }
    @patch_params = {
      id: id,
      'user-forename' => 'Aaaddd',
      'user-lastname' => 'Bbbeeee',
      email: "#{id}2@evercam.io",
      password: 'asdf',
      country: 'pl'
    }
  end

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
      post :create, @params
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
        request.cookies['user'] = 'tj@mhlabs.net'
        get :settings, {id: 'tester'}
        expect(response.status).to eq(200)
        expect(response).to render_template :settings
      end
    end

    describe 'POST #settings_update with wrong params' do
      it "fails and renders user settings" do
        request.cookies['user'] = @params[:user][:email]
        post :settings_update, {id: @params[:user][:username]}
        expect(response.status).to eq(200)
        expect(response).to render_template :settings
        expect(flash[:message]).to eq(["forename can't be blank", "lastname can't be blank",
                                       "country can't be blank", "email can't be blank",
                                       "country is invalid"])
      end
    end

    describe 'POST #settings_update with correct params, but for different user' do
      it "signs out and redirects to sign in" do
        request.cookies['user'] = @params[:user][:email]
        post :settings_update, {id: 'tester'}
        expect(response.status).to eq(302)
        expect(response).to redirect_to '/signin'
      end
    end

    describe 'POST #settings_update with correct params' do
      it "updates and renders user settings" do
        request.cookies['user'] = @params[:user][:email]
        post :settings_update, @patch_params
        expect(response.status).to eq(200)
        expect(response).to render_template :settings
        expect(flash[:message]).to eq('Settings updated successfully')
      end
    end
  end

end
