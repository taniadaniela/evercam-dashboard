class UserMailer < ActionMailer::Base
   default from: "noreply@evercam.io"

   # This method dispatches an email whenever a user chooses to share a camera
   # with a user that doesn't currently possess an Evercam account.
   def sign_up_to_share_email(email, camera_id, user, key)
      @camera_id = camera_id
      @user      = user
      @key       = key
      mail(to: email, subject: "#{user.username} has shared a camera with you")
   end
end
