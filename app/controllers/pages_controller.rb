class PagesController < ApplicationController
  include SessionsHelper

  def dev
    current_user
  end

end