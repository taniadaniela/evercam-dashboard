require 'spec_helper'

describe CamerasController do
  describe 'GET #index without auth' do
    it "redirects to signup" do
      get :index
      expect(response).to redirect_to('/signin')
    end
  end

  describe 'GET #new without auth' do
    it "redirects to signup" do
      get :new
      expect(response).to redirect_to('/signin')
    end
  end

  describe 'POST #new without auth' do
    it "redirects to signup" do
      post :new
      expect(response).to redirect_to('/signin')
    end
  end

  context 'with auth' do
    describe 'GET #index' do
      it "renders the :index" do
        request.cookies['user'] = 'tj@mhlabs.net'
        get :index
        expect(response.status).to eq(200)
        expect(response).to render_template :index
      end
    end

    describe 'GET #new' do
      it "renders the :new" do
        request.cookies['user'] = 'tj@mhlabs.net'
        get :new
        expect(response.status).to eq(200)
        expect(response).to render_template :new
      end
    end

    before(:all) do
      id = SecureRandom.uuid
      @params = {
        'camera-id' => id,
        'camera-name' => 'My Cam',
        'camera-url' => '1.1.1.1',
        'snapshot' => '/jpg',
        'camera-username' => '',
        'camera-password' => '',
        'camera-vendor' => '',
        'local-http' => '',
        'port' => '',
        'local-ip' => ''
      }
      @patch_params = {
        'camera-id' => id,
        'id' => id,
        'camera-name' => 'My New Cam',
        'camera-url' => '1.1.1.2',
        'snapshot' => '/jpeg',
        'camera-username' => '',
        'camera-password' => '',
        'camera-vendor' => '',
        'local-http' => '',
        'port' => '',
        'local-ip' => ''
      }
    end

    describe 'POST #create with valid parameters' do
      it "redirects to the newly created camera" do
        request.cookies['user'] = 'tj@mhlabs.net'
        post :create, @params
        expect(response.status).to eq(302)
        expect(response).to redirect_to("/cameras/#{@params['camera-id']}")
      end
    end

    describe 'POST #create with missing parameters' do
      it "renders new camera form" do
        request.cookies['user'] = 'tj@mhlabs.net'
        post :create, {}
        expect(response.status).to eq(200)
        expect(response).to render_template :new
      end
    end

    describe 'POST #update with valid parameters' do
      it "redirects to the updated camera" do
        request.cookies['user'] = 'tj@mhlabs.net'
        post :update, @patch_params
        expect(response.status).to eq(302)
        expect(response).to redirect_to "/cameras/#{@params['camera-id']}#settings"
        expect(flash[:message]).to eq('Settings updated successfully')
      end
    end

    describe 'POST #update with missing parameters' do
      it "renders camera settings form" do
        request.cookies['user'] = 'tj@mhlabs.net'
        post :update, {'id' => @params['camera-id'], 'camera-id' => @params['camera-id']}
        expect(response.status).to eq(200)
        expect(response).to render_template :single
        expect(flash[:message]).to eq(["name can't be blank", "jpg url can't be blank", "external host can't be blank"])
      end
    end


    describe 'GET #single' do
      it "renders the :single" do
        request.cookies['user'] = 'tj@mhlabs.net'
        get :single, {'id' => @params['camera-id']}
        expect(response.status).to eq(200)
        expect(response).to render_template :single
      end
    end

  end
end
