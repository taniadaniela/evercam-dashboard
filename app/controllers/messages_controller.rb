class MessagesController < ApplicationController
  before_filter :authenticate_user!

  include SessionsHelper
  include ApplicationHelper

  def new
    @cameras = load_user_cameras(true, false)
    @message = Message.new
  end

  def create
    @cameras = load_user_cameras(true, false)
    @message = Message.new(message_params)

    if @message.valid?
      MessageMailer.new_message(@message).deliver
      redirect_to contact_path
      flash[:message] = "Sent successfully."
    else
      flash[:notice] = "An error occurred while sending this message."
      render :new
    end
  end

  private

  def message_params
    params.require(:message).permit(:name, :email, :content)
  end
end
