require 'spec_helper'
require 'json'
require_relative 'stub_helper'

describe "sharing actions", :type => :feature, :focus=>true, :js => true do

  let!(:user) {
    create(:active_user, :password => 'pass')
  }

  let!(:user2) {
    create(:active_user, :password => 'pass')
  }

  it "User shares his camera" do
    cameras_stubs(user)

    stub_request(:get, "#{EVERCAM_API}users/#{user.username}/cameras.json?api_id=#{user.api_id}&api_key=#{user.api_key}&include_shared=true").
        to_return(:status => 200, :body => {:cameras => [{:id => 'testcam', :name => 'Test Camera', :rights => 'edit'}]}.to_json, :headers => {})

    stub_request(:get, "#{EVERCAM_API}cameras/testcam.json?api_id=#{user.api_id}&api_key=#{user.api_key}").
        to_return(:status => 200, :body => '{"cameras": [{"name": "Test Camera", "id": "testcam", "rights": "edit"}]}', :headers => {})

    page.set_rack_session(:user => user.email)
    visit "/"
    first(:link, 'Test Camera').click
    click_link 'Sharing'

    fill_in('sharingUserEmail', :with => user2.email)

    click_link 'Share'
  end

end