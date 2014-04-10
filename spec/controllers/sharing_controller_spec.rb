require 'spec_helper'

describe SharingController do
   describe '#update_camera' do
      let!(:camera) {
         create(:private_camera)
      }

      let!(:other_camera) {
         create(:private_camera)
      }

      let(:owner) {
         camera.owner
      }

      let(:credentials) {
         {api_id: owner.api_id, api_key: owner.api_key}
      }

      let(:parameters) {
         {:discoverable => false,
          :id =>           camera.exid,
          :public =>       false}
      }

      it "returns success for a valid request" do
         stub_request(:patch, "https://api.evercam.io/v1//cameras/#{camera.exid}?api_id=#{owner.api_id}&api_key=#{owner.api_key}").
            to_return(:status => 200, :body => "", :headers => {})

         post :update_camera, parameters.merge(credentials), {user: owner.email}
         expect(response.status).to eq(200)
         output = JSON.parse(response.body)
         expect(output.include?("success")).to eq(true)
         expect(output["success"]).to eq(true)
      end

      it "returns failure for an non-existent camera" do
         stub_request(:patch, "https://api.evercam.io/v1//cameras/blah?api_id=#{owner.api_id}&api_key=#{owner.api_key}").
            to_return(:status => 404, :body => "", :headers => {})

         parameters[:id]  = "blah"
         post :update_camera, parameters.merge(credentials), {user: owner.email}
         expect(response.status).to eq(200)
         output = JSON.parse(response.body)
         expect(output.include?("success")).to eq(true)
         expect(output.include?("message")).to eq(true)
         expect(output["success"]).to eq(false)
         expect(output["message"]).to eq("Failed to update camera permissions.")
      end

      it "returns failure for a camera that is owned by someone else" do
         stub_request(:patch, "https://api.evercam.io/v1//cameras/#{other_camera.exid}?api_id=#{owner.api_id}&api_key=#{owner.api_key}").
            to_return(:status => 403, :body => "", :headers => {})

         parameters[:id]  = other_camera.exid
         post :update_camera, parameters.merge(credentials), {user: owner.email}
         expect(response.status).to eq(200)
         output = JSON.parse(response.body)
         expect(output.include?("success")).to eq(true)
         expect(output.include?("message")).to eq(true)
         expect(output["success"]).to eq(false)
         expect(output["message"]).to eq("Failed to update camera permissions.")
      end
   end
end