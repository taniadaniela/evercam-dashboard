class SharingController < ApplicationController
   before_filter :authenticate_user!

  include SessionsHelper
  include ApplicationHelper

   def update_camera
      result    = {success: true}
      if params[:id] && !params[:public].nil? && !params[:discoverable].nil?
         values    = {id: params[:id],
                      is_public: params[:public],
                      discoverable: (params[:discoverable] == "true")}
         response  = API_call("/cameras/#{params[:id]}", :patch, values)
         if !response.success?
            Rails.logger.warn "API call failed. Status code returned was #{response.code}. "\
                              "Response body is '#{response.body}'."
            result[:success] = false
            result[:message] = "Failed to update camera permissions."
         end
      else
         result = {success: false, message: "Insufficient parameters provided."}
      end

      render json: result
   end

   def delete
      result   = {success: true}
      if params[:camera_id] && params[:share_id]
         values   = {share_id: params[:share_id]}
         response = API_call("/cameras/#{params[:camera_id]}/share", :delete, values)
         if !response.success?
            Rails.logger.warn "API call failed. Status code returned was #{response.code}. "\
                              "Response body is '#{response.body}'."
            result[:success] = false
            result[:message] = "Failed to delete camera share."
         end
      else
         result = {success: false, message: "Insufficient parameters provided."}
      end
      render json: result
   end

   def create
      result = {success: true}
      if params[:camera_id] && params[:permissions] && params[:email]
         camera_id = params[:camera_id]
         rights = [AccessRight::LIST, AccessRight::SNAPSHOT]
         rights.concat([AccessRight::VIEW, AccessRight::EDIT, AccessRight::DELETE]) if params[:permissions] == "full"
         values   = {email: params[:email], rights: rights.join(",")}
         response = API_call("/cameras/#{camera_id}/share", :post, values)

         data  = JSON.parse(response.body)
         share = data["shares"][0]
         result[:camera_id] = share["camera_id"]
         result[:share_id]  = share["id"]
         result[:permissions] = params[:permissions]
         result[:email]       = params[:email]
      else
         result = {success: false, message: "Insufficient parameters provided."}
      end
      render json: result
   end
end
