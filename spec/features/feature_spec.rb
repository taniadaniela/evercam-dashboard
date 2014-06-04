require 'spec_helper'

describe "the signin process", :type => :feature do

  let!(:user) {
    create(:active_user, :password => 'pass')
  }

  context "Session management" do
    it "User sings in with correct password" do
      stub_request(:get, "#{EVERCAM_API}users/#{user.username}/cameras.json?api_id=#{user.api_id}&api_key=#{user.api_key}&include_shared=true").
        to_return(:status => 200, :body => '{"cameras": []}', :headers => {})

      stub_request(:get, "#{EVERCAM_API}shares/users/#{user.username}?api_id=#{user.api_id}&api_key=#{user.api_key}").
        to_return(:status => 200, :body => "{}", :headers => {})

      visit "/"
      fill_in "Email", :with => user.email
      fill_in "Password", :with => 'pass'
      click_button "Sign in"

      expect(page).to have_text("My Cameras")
    end

    it "User signs in with incorrect password" do
      visit "/"
      fill_in "Email", :with => user.email
      fill_in "Password", :with => 'xxx'
      click_button "Sign in"

      expect(page.html.include?("Notification.show('Invalid login/password combination')")).to eq(true)
    end
  end

  context "Camera management" do
    it "User adds new camera with correct parameters" do
      stub_request(:post, "#{EVERCAM_API}cameras.json").
        to_return(:status => 200, :body => '{"cameras": [{"id": "testcam", "name": "Test Camera"}]}', :headers => {})

      stub_request(:get, "#{EVERCAM_API}cameras/testcam.json?api_id=#{user.api_id}&api_key=#{user.api_key}").
        to_return(:status => 200, :body => '{"cameras": [{"name": "Test Camera", "id": "testcam", "rights": ""}]}', :headers => {})

      stub_request(:get, "#{EVERCAM_API}shares/cameras/testcam.json?api_id=#{user.api_id}&api_key=#{user.api_key}").
        to_return(:status => 200, :body => '{"shares": []}', :headers => {})

      stub_request(:get, "#{EVERCAM_API}users/#{user.username}/cameras.json?api_id=#{user.api_id}&api_key=#{user.api_key}&include_shared=true").
        to_return(:status => 200, :body => '{"cameras": []}', :headers => {})

      stub_request(:get, "#{EVERCAM_API}users/#{user.username}/cameras.json?api_id=#{user.api_id}&api_key=#{user.api_key}&include_shared=false").
         to_return(:status => 200, :body => '{"cameras": []}', :headers => {})

      stub_request(:get, "#{EVERCAM_API}shares/requests/testcam.json?api_id=#{user.api_id}&api_key=#{user.api_key}&status=PENDING").
        to_return(:status => 200, :body => '{"share_requests": []}', :headers => {})

      stub_request(:get, "#{EVERCAM_API}shares.json?api_id=#{user.api_id}&api_key=#{user.api_key}&camera_id=testcam&user_id=#{user.username}").
         to_return(:status => 200, :body => '{"shares": [{}]}', :headers => {})

      stub_request(:get, "#{EVERCAM_API}cameras/testcam/logs.json?api_id=#{user.api_id}&api_key=#{user.api_key}&objects=true&page=-1&types=").
         to_return(:status => 200, :body => '{"logs": [], "pages": 1}', :headers => {})
      
      stub_request(:get, "#{EVERCAM_API}cameras/testcam/snapshots/latest.json?api_id=#{user.api_id}&api_key=#{user.api_key}&with_data=true").
        to_return(:status => 200, :body => '{"snapshots": []}', :headers => {})

      stub_request(:post, "#{EVERCAM_API}cameras/testcam/snapshots.json").
         with(:body => {"api_id"=>"#{user.api_id}", "api_key"=>"#{user.api_key}", "notes"=>"Initial snapshot"},
              :headers => {'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Faraday v0.9.0'}).
         to_return(:status => 200, :body => '{"snapshots": [{"camera": "aaaa11123","notes": null,"created_at": 1401205738,"timezone": "Etc/UTC"}]}', :headers => {})



      page.set_rack_session(:user => user.email)
      visit "/cameras/new"
      fill_in "Friendly Name", :with => 'Test Camera'
      fill_in "Evercam ID", :with => 'testcam'
      fill_in "camera-url", :with => '1.1.1.1'
      fill_in "port", :with => '123'
      fill_in "Snapshot URL", :with => '/snapshot.jpg'
      click_button "Finish & Add"

      # puts "PAGE:\n#{page.public_methods.sort.join("\n")}"
      expect(page).to have_text("Test Camera")
      expect(page).to have_text("testcam")
      expect(page).to have_text("Live View")
    end

  end


end
