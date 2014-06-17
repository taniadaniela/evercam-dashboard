class SharingController < ApplicationController
   before_filter :authenticate_user!

  include SessionsHelper
  include ApplicationHelper

   def update_camera
      result    = {success: true}
      if params[:id] && !params[:public].nil? && !params[:discoverable].nil?
         begin
            values    = {id: params[:id],
                         is_public: params[:public],
                         discoverable: (params[:discoverable] == "true")}
            api = get_evercam_api
            api.update_camera(params[:id], values)
         rescue => error
            env["airbrake.error_id"] = notify_airbrake(error)
            Rails.logger.warn "Exception caught updating camera permissions.\n"\
                              "Cause: #{error}\n" + error.backtrace.join("\n")
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
         begin
            get_evercam_api.delete_camera_share(params[:camera_id], params[:share_id])
         rescue => error
            env["airbrake.error_id"] = notify_airbrake(error)
            Rails.logger.warn "Exception caught deleting camera share.\n"\
                              "Cause: #{error}\n" + error.backtrace.join("\n")
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
         begin
            get_evercam_api.cancel_camera_share_request(params[:camera_id], params[:email])
         rescue => error
            env["airbrake.error_id"] = notify_airbrake(error)
            Rails.logger.warn "Exception caught cancelling camera share request.\n"\
                              "Cause: #{error}\n" + error.backtrace.join("\n")
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
         rights = generate_rights_list(params[:permissions])
         share  = nil
         begin
            share = get_evercam_api.share_camera(camera_id, params[:email], rights)
            result[:camera_id]   = share["camera_id"]
            result[:share_id]    = share["id"]
            result[:type]        = share["type"]
            result[:permissions] = params[:permissions]
            result[:email]       = share["email"]
            if share["type"] == "share"
               UserMailer.camera_shared_notification(params[:email],
                                                     params[:camera_id],
                                                     current_user).deliver
            else
               UserMailer.sign_up_to_share_email(params[:email],
                                                 params[:camera_id],
                                                 current_user,
                                                 share["id"]).deliver
            end
         rescue => error
            env["airbrake.error_id"] = notify_airbrake(error)
            Rails.logger.warn "Exception caught creating camera share.\n"\
                              "Cause: #{error}\n" + error.backtrace.join("\n")
            result[:success] = false
            result[:message] = error.message
            result[:code]    = error.code
         end
      else
         result = {success: false,
                   message: "Insufficient parameters provided.",
                   code: "insufficient_parameters"}
      end
      render json: result
   end

   def update_share
      result = {success: true}
      if params.include?(:id) && params.include?(:permissions)
         rights = generate_rights_list(params[:permissions])
         begin
            get_evercam_api.update_camera_share(params[:id], rights)
         rescue => error
            env["airbrake.error_id"] = notify_airbrake(error)
            Rails.logger.warn "Exception caught updating camera share.\n"\
                              "Cause: #{error}\n" + error.backtrace.join("\n")
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
         begin
            get_evercam_api.update_camera_share_request(params[:id], rights)
         rescue => error
            env["airbrake.error_id"] = notify_airbrake(error)
            Rails.logger.warn "Exception caught updating camera share.\n"\
                              "Cause: #{error}\n" + error.backtrace.join("\n")
            result = {success: false, message: "Failed to update share request. Please contact support."}
         end
      else
         result = {success: false, message: "Insufficient parameters provided."}
      end
      render json: result
   end

   private

   def generate_rights_list(permissions)
      rights = [AccessRight::LIST, AccessRight::SNAPSHOT]
      if permissions == "full"
         AccessRight::BASE_RIGHTS.each do |right|
            if right != AccessRight::DELETE
               rights << right if !rights.include?(right)
               rights << "#{AccessRight::GRANT}~#{right}"
            end
         end
      end
      rights
   end
end
