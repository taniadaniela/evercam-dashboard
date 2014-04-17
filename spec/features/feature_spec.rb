require 'spec_helper'

describe "the signin process", :type => :feature do

  let!(:user) {
    create(:active_user, :password => 'pass')
  }

  context "Session management" do
    it "User sings in with correct password" do
      stub_request(:get, "#{EVERCAM_API}users/#{user.username}/cameras?api_id=#{user.api_id}&api_key=#{user.api_key}").
        to_return(:status => 200, :body => '{"cameras": []}', :headers => {})

      visit "/"
      fill_in "Email", :with => user.email
      fill_in "Password", :with => 'pass'
      click_button "Sign in"

      expect(page).to have_text("My Cameras")
    end

    it "User sings in with incorrect password" do
      visit "/"
      fill_in "Email", :with => user.email
      fill_in "Password", :with => 'xxx'
      click_button "Sign in"

      expect(page).to have_text("Invalid")
    end
  end

  context "Camera management" do
    it "User adds new camera with correct parameters" do
      stub_request(:post, "#{EVERCAM_API}cameras").
        to_return(:status => 200, :body => "", :headers => {})

      stub_request(:get, "#{EVERCAM_API}cameras/testcam?api_id=#{user.api_id}&api_key=#{user.api_key}").
        to_return(:status => 200, :body => '{"cameras": [{"name": "Test Camera", "id": "testcam"}]}', :headers => {})

      stub_request(:get, "#{EVERCAM_API}cameras/testcam/shares?api_id=#{user.api_id}&api_key=#{user.api_key}").
        with(:headers => {'User-Agent'=>'Typhoeus - https://github.com/typhoeus/typhoeus'}).
        to_return(:status => 200, :body => "{}", :headers => {})

      stub_request(:get, "#{EVERCAM_API}users/#{user.username}/cameras?api_id=#{user.api_id}&api_key=#{user.api_key}").
        to_return(:status => 200, :body => '{"cameras": []}', :headers => {})


      page.set_rack_session(:user => user.email)
      visit "/cameras/new"
      fill_in "Friendly Name", :with => 'Test Camera'
      fill_in "Evercam ID", :with => 'testcam'
      fill_in "camera-url", :with => '1.1.1.1'
      fill_in "port", :with => '123'
      fill_in "Snapshot URL", :with => '/snapshot.jpg'
      click_button "Finish & Add"

      expect(page).to have_text("Test Camera")
      expect(page).to have_text("testcam")
      expect(page).to have_text("Live View")
    end

  end


end