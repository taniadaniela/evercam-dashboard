require 'spec_helper'
require 'json'
require_relative 'stub_helper'

describe "sharing actions", :type => :feature, :js => true do

  let!(:user) {
    create(:active_user, :password => 'pass')
  }

  let!(:user2) {
    create(:active_user, :password => 'pass')
  }

  it "User shares his camera" do
    cameras_stubs(user)

    page.set_rack_session(:user => user.email)
    visit "/"
    first(:link, 'Test Camera').click
    click_link 'Sharing'

    fill_in('sharingUserEmail', :with => user2.email)

    click_link 'Share'
  end

end