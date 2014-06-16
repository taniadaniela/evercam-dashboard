require 'spec_helper'
require_relative 'stub_helper'

describe "user settings actions", :type => :feature, :focus=>true, :js => true do

  let!(:user) {
    create(:active_user, :password => 'pass')
  }

  it "User goes to his settings" do
    cameras_stubs(user)
    page.set_rack_session(:user => user.email)
    visit "/"
    click_link user.username
    click_link 'Settings'

    expect(page).to have_text("User Account Settings")

  end

  it "User goes to his settings" do
    cameras_stubs(user)
    page.set_rack_session(:user => user.email)
    visit "/users/#{user.username}/settings"

    fill_in('user-forename', :with => 'AAA')
    fill_in('user-lastname', :with => 'BBB')
    fill_in('email', :with => 'test@test.ie')

    click_button 'Save'

    expect(page).to have_text("Settings updated successfully")

  end

end