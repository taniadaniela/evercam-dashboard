require 'test_helper'

class CamerasControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
