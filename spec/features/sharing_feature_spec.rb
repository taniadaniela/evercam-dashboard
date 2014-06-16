require 'spec_helper'
require_relative 'stub_helper'

describe "sharing actions", :type => :feature, :focus=>true do

  let!(:user) {
    create(:active_user, :password => 'pass')
  }

  it "User shares his camera" do
    cameras_stubs(user)

    stub_request(:get, "#{EVERCAM_API}users/#{user.username}/cameras.json?api_id=#{user.api_id}&api_key=#{user.api_key}&include_shared=true").
        to_return(:status => 200, :body => '{"cameras": [{"id": "testcam", "name": "Test Camera"}]}', :headers => {})

    page.set_rack_session(:user => user.email)
    visit "/"
    first(:link, 'Test Camera').click

    puts page.body

  end

end