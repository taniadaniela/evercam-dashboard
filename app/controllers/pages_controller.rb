class PagesController < ApplicationController
  include SessionsHelper
  layout "forswagger", only: [:swagger]

  def dev
    current_user
  end

  def widgets
    current_user
  end

  def swagger
    response.headers["X-Frame-Options"] = "ALLOWALL"
    current_user
  end

end