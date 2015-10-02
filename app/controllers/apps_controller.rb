class AppsController < ApplicationController
  before_filter :authenticate_user!
  include SessionsHelper
  include ApplicationHelper
  layout "user-account"

  def index
    # This is temporary solution to get data for each application using multiple queries.
    @apps = []
    query = AccessToken.where(grantor: current_user).and(is_revoked: false).and("expires_at > '#{Time.now}'")
    @apps[@apps.count] = query.and(client_id: 2).last
    @apps[@apps.count] = query.and(client_id: 4).last
    @apps[@apps.count] = query.and(client_id: 5).last
    @apps[@apps.count] = query.and(client_id: 7).last
    @apps[@apps.count] = query.and(client_id: 8).last
    @apps[@apps.count] = query.and(client_id: 12).last
    @apps[@apps.count] = query.and(client_id: 13).last
    @apps[@apps.count] = query.and(client_id: 14).last
    @apps[@apps.count] = query.and(client_id: 15).last
    @apps[@apps.count] = query.and(client_id: 18).last
    @apps[@apps.count] = query.and(client_id: 19).last
    @apps = @apps.compact
  end

  def revoke
    redirect_to apps_path(current_user.username)
  end
end