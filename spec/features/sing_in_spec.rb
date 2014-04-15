require "spec_helper"

describe "the signin process", :type => :feature do

  let!(:user) {
    create(:active_user, :password => 'pass')
  }

  context "Session management" do
    it "User sings in with correct password" do
      stub_request(:get, "https://api.evercam.io/v1/users/#{user.username}/cameras?api_id=#{user.api_id}&api_key=#{user.api_key}").
        to_return(:status => 200, :body => '{"cameras": []}', :headers => {})

      visit "/"
      fill_in "session_email", :with => user.email
      fill_in "session[password]", :with => 'pass'
      click_button "Sign in"

      expect(page).to have_text("My Cameras")
    end
  end
end