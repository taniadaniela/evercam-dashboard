require 'spec_helper'
require_relative 'stub_helper'

describe "public cams actions", :type => :feature do

  let!(:user) {
    create(:active_user, :password => 'pass')
  }

  it "User clicks Add Public Camera button" do
    stub_request(:get, "#{EVERCAM_API}public/cameras.json?api_id=#{user.api_id}&api_key=#{user.api_key}&limit=9&offset=0").
      to_return(:status => 200, :body => IO.read('spec/features/fixtures/public_cams.json'), :headers => {})

    cameras_stubs(user)
    page.set_rack_session(:user => user.email)
    visit "/"
    click_link "Add Public Camera"

    expect(page).to have_text("Add a Public Camera")
    expect(page).to have_text("Emerald Hills Cam - Cali")

    # There should be 10 pages of cameras
    expect(find_link('10').visible?).to be_truthy

  end

end