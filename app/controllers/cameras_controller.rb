class CamerasController < ApplicationController
  def index
  end

  def create
    if false
      redirect_to :cameras_index
    else
      render :new
    end
  end
end
