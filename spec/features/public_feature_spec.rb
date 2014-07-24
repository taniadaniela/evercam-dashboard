require 'spec_helper'
require_relative '../stub_helper'

describe "public cams actions", :type => :feature, :js => true do

  let!(:user) {
    create(:active_user, :password => 'pass')
  }

  it "User clicks Public Cameras button" do
    stub_request(:get, "#{EVERCAM_API}public/cameras.json?api_id=#{user.api_id}&api_key=#{user.api_key}&offset=0&thumbnail=true").
      to_return(:status => 200, :body => IO.read('spec/features/fixtures/public_cams.json'), :headers => {})
    cameras_stubs(user)

    page.set_rack_session(:user => user.email)

    visit "/"
    click_link "Public Cameras"

    expect(page.html).to include('<div id="map-canvas"')

  end

end