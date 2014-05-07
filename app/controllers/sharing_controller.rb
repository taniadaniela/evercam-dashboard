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
         response  = API_call("cameras/#{params[:id]}", :patch, values)
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
         response = API_call("/shares/camera/#{params[:camera_id]}", :delete, values)
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

   def cancel_share_request
      result = {success: true}
      if params[:camera_id] && params[:email]
         values = {email: params[:email]}
         response = API_call("/shares/requests/#{params[:camera_id]}", :delete, values)
         if !response.success?
            Rails.logger.warn "API call failed. Status code returned was #{response.code}. "\
                              "Response body is '#{response.body}'."
            result[:success] = false
            result[:message] = "Failed to delete camera share request."
         end
      else
         result = {success: false, message: "Insufficient parameters provided."}
      end
      render json: result
   end

   def create
      result = {success: true}
      if params.include?(:camera_id) && params.include?(:permissions) && params.include?(:email)
         camera_id = params[:camera_id]
         rights = [AccessRight::LIST, AccessRight::SNAPSHOT]
         rights.concat([AccessRight::VIEW, AccessRight::EDIT, AccessRight::DELETE]) if params[:permissions] == "full"
         values   = {email: params[:email], rights: rights.join(",")}
         response = API_call("/shares/camera/#{camera_id}", :post, values)

         data  = JSON.parse(response.body)
         if response.success?
            if data.include?("shares")
               share = data["shares"][0]
               result[:camera_id]   = share["camera_id"]
               result[:share_id]    = share["id"]
               result[:type]        = "share"
               UserMailer.camera_shared_notification(params[:email],
                                                     params[:camera_id],
                                                     current_user).deliver
            else
               share_request = data["share_requests"][0]
               result[:camera_id]   = share_request["camera_id"]
               result[:share_id]    = share_request["id"]
               result[:type]        = "share_request"
               UserMailer.sign_up_to_share_email(params[:email],
                                                 params[:camera_id],
                                                 current_user,
                                                 share_request["id"]).deliver
            end
            result[:permissions] = params[:permissions]
            result[:email]       = params[:email]
         else
            result[:success] = false
            result[:message] = "Failed to create camera share."
         end
      else
         result = {success: false, message: "Insufficient parameters provided."}
      end
      render json: result
   end

   def update_share
      result = {success: true}
      if params.include?(:id) && params.include?(:permissions)
         rights = [AccessRight::LIST, AccessRight::SNAPSHOT]
         rights.concat([AccessRight::VIEW, AccessRight::EDIT, AccessRight::DELETE]) if params[:permissions] == "full"
         values   = {rights: rights.join(",")}
         response = API_call("/shares/camera/#{params[:id]}", :patch, values)
         if !response.success?
            result = {success: false, message: "Failed to update share. Please contact support."}
         end
      else
         result = {success: false, message: "Insufficient parameters provided."}
      end
      render json: result
   end

   def update_share_request
      result = {success: true}
      if params.include?(:id) && params.include?(:permissions)
         rights = [AccessRight::LIST, AccessRight::SNAPSHOT]
         rights.concat([AccessRight::VIEW, AccessRight::EDIT, AccessRight::DELETE]) if params[:permissions] == "full"
         values   = {rights: rights.join(",")}
         response = API_call("/shares/requests/#{params[:id]}", :patch, values)
         if !response.success?
            result = {success: false, message: "Failed to update share request. Please contact support."}
         end
      else
         result = {success: false, message: "Insufficient parameters provided."}
      end
      render json: result
   end
end
