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

  describe 'GET #index with auth' do
    it "renders the :index" do
      request.cookies['user'] = 'tj@mhlabs.net'
      get :index
      expect(response.status).to eq(200)
      expect(response).to render_template :index
    end
  end

  describe 'GET #new with auth' do
    it "renders the :new" do
      request.cookies['user'] = 'tj@mhlabs.net'
      get :new
      expect(response.status).to eq(200)
      expect(response).to render_template :new
    end
  end
end
