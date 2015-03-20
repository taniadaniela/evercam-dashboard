class UserMailer < ActionMailer::Base
  default from: "support@evercam.io"
  default to: "support@evercam.io"

   # This method dispatches an email whenever a user chooses to share a camera
   # with a user that doesn't currently possess an Evercam account.
   def sign_up_to_share_email(email, camera_id, user, key, snapshot)
      @camera_id = camera_id
      @user      = user
      @key       = key
      @snapshot  = snapshot
      mail(to: email, subject: "#{user.username} has shared a camera with you")
   end

   # This method dispatches an email to an Evercam user whenever another user
   # shares a camera with them.
   def camera_shared_notification(email, camera_id, user, snapshot)
      @camera_id = camera_id
      @user      = user
      @add_snap = false
      unless snapshot.nil?
        attachments.inline['snapshot.jpg'] = snapshot
        @add_snap = true
      end
      mail(to: email, subject: "#{user.username} has shared a camera with you")
   end

   def password_reset(email, user, token)
      @token    = token
      @user     = user
      mail(to: email, subject: "Password reset requested for Evercam")
   end

  def resend_confirmation_email(user, code)
      @user    = user
      @code    = code
      mail(to: user.email, subject: "Evercam Confirmation")
  end

  def new_message(message)
    @message = message

    mail subject: "Message from #{message.name}"
  end

end
