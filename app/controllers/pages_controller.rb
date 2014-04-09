class PagesController < ApplicationController
  include SessionsHelper
  layout "forswagger", only: [:swagger]

  def dev
    current_user
  end

  def swagger
    current_user
  end

end