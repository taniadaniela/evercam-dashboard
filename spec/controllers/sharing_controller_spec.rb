require 'spec_helper'

describe SharingController do
   describe '#update_camera' do
      let!(:camera) {
         create(:private_camera)
      }

      let(:owner) {
         camera.owner
      }

      let(:credentials) {
         {api_id: owner.api_id, api_key: owner.api_key}
      }

      it "returns success for a valid request" do
         #stub_request(:post, "https://api.evercam.io/v1/users").to_return(:status => 200, :body => "", :headers => {})
         parameters = {public: false, discoverable: false}.merge(credentials)
         post :update_camera, parameters
         expect(response.status).to eq(200)
         output = JSON.parse(response.body)
         expect(output.include?("success")).to eq(true)
         expect(output["success"]).to eq(true)
      end
   end
end