class MessagesController < ApplicationController
  before_filter :authenticate_user!

  include SessionsHelper
  include ApplicationHelper

  def new
    @cameras = load_user_cameras(true, false)
    @message = Message.new
  end

  def create
    @message = Message.new(message_params)

    if @message.valid?
      UserMailer.new_message(@message).deliver
      redirect_to contact_path, notice: "Your messages has been sent."
    else
      flash[:alert] = "An error occurred while delivering this message."
      render :new
    end
  end

  private

  def message_params
    params.require(:message).permit(:name, :email, :content)
  end
end
