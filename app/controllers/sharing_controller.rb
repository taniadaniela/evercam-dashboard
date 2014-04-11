class SharingController < ApplicationController
   before_filter :authenticate_user!

  include SessionsHelper
  include ApplicationHelper

   def update_camera
      result    = {success: true}
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

      render json: result
   end

   def delete
      result   = {success: true}
      values   = {share_id: params[:share_id]}
      response = API_call("/cameras/#{params[:camera_id]}/share", :delete, values)
      if !response.success?
         Rails.logger.warn "API call failed. Status code returned was #{response.code}. "\
                           "Response body is '#{response.body}'."
         result[:success] = false
         result[:message] = "Failed to delete camera share."
      end
      render json: result
   end
end
