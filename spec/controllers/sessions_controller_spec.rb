require 'spec_helper'

describe SessionsController, :focus => true do

  describe 'POST #create without auth' do
    it "rerenders signin" do
      post :create
      expect(response).to render_template :new
    end
  end

  describe 'POST #create with wrong credentials' do
    it "rerenders signin" do
      post :create, {session: {email: 'tj@mhlabs.net', password: 'xxx'}}
      expect(response).to render_template :new
    end
  end

  describe 'POST #create with correct credentials' do
    it "rerenders signin" do
      post :create, {session: {email: 'tj@mhlabs.net', password: 'DBNeSvfKymBWIVlHgwQt'}}
      expect(response).to redirect_to :cameras_index
    end
  end

  describe 'DELETE #destroy with correct credentials' do
    it "redirects to signin" do
      delete :destroy
      expect(response).to redirect_to '/signin'
    end
  end

end
