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

      it "returns failure if a public parameter is not specified" do
         parameters.delete(:public)
         post :update_camera, parameters.merge(credentials), {user: owner.email}
         expect(response.status).to eq(200)
         output = JSON.parse(response.body)
         expect(output.include?("success")).to eq(true)
         expect(output.include?("message")).to eq(true)
         expect(output["success"]).to eq(false)
         expect(output["message"]).to eq("Insufficient parameters provided.")
      end

      it "returns failure if a discoverable parameter is not specified" do
         parameters.delete(:discoverable)
         post :update_camera, parameters.merge(credentials), {user: owner.email}
         expect(response.status).to eq(200)
         output = JSON.parse(response.body)
         expect(output.include?("success")).to eq(true)
         expect(output.include?("message")).to eq(true)
         expect(output["success"]).to eq(false)
         expect(output["message"]).to eq("Insufficient parameters provided.")
      end
   end

   describe 'DELETE /share' do
      let!(:camera) {
         create(:private_camera)
      }

      let!(:share) {
         create(:private_share, camera: camera, user: camera.owner)
      }

      let(:owner) {
         camera.owner
      }

      let(:credentials) {
         {api_id: owner.api_id, api_key: owner.api_key}
      }

      let(:parameters) {
         {:camera_id => camera.exid,
          :share_id => share.id}
      }

      it 'returns failure if a camera_id is not specified' do
         parameters.delete(:camera_id)
         delete :delete, parameters.merge(credentials), {user: owner.email}
         expect(response.status).to eq(200)
         output = JSON.parse(response.body)
         expect(output.include?("success")).to eq(true)
         expect(output.include?("message")).to eq(true)
         expect(output["success"]).to eq(false)
         expect(output["message"]).to eq("Insufficient parameters provided.")
      end

      it 'returns failure if a share_id is not specified' do
         parameters.delete(:share_id)
         delete :delete, parameters.merge(credentials), {user: owner.email}
         expect(response.status).to eq(200)
         output = JSON.parse(response.body)
         expect(output.include?("success")).to eq(true)
         expect(output.include?("message")).to eq(true)
         expect(output["success"]).to eq(false)
         expect(output["message"]).to eq("Insufficient parameters provided.")
      end

      it 'returns failure if it gets a negative response from the API call' do
         stub_request(:delete, "https://api.evercam.io/v1//cameras/#{camera.exid}/share?api_id=#{owner.api_id}&api_key=#{owner.api_key}").
            to_return(:status => 403, :body => "", :headers => {})

         delete :delete, parameters.merge(credentials), {user: owner.email}
         expect(response.status).to eq(200)
         output = JSON.parse(response.body)
         expect(output.include?("success")).to eq(true)
         expect(output.include?("message")).to eq(true)
         expect(output["success"]).to eq(false)
         expect(output["message"]).to eq("Failed to delete camera share.")
      end

      it 'returns success if it gets a positive response from the API call' do
         stub_request(:delete, "https://api.evercam.io/v1//cameras/#{camera.exid}/share?api_id=#{owner.api_id}&api_key=#{owner.api_key}").
            to_return(:status => 200, :body => "", :headers => {})

         delete :delete, parameters.merge(credentials), {user: owner.email}
         expect(response.status).to eq(200)
         output = JSON.parse(response.body)
         expect(output.include?("success")).to eq(true)
         expect(output["success"]).to eq(true)
      end
   end
end