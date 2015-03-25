class MessageMailer < ApplicationMailer
  default from: "Evercam Support <%= @message.email %>"
  default to: "Support <ciaran@evercam.io>"
  default reply_to: "<%= @message.email %>"

  def new_message(message)
    @message = message

    mail subject: "Message from #{message.name}"
  end

end
