require 'test_helper'

class CamerasControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get new camera form" do
    get :new
    assert_response :success
  end

  test "should post new camera form" do
    post :new
    assert_response :success
  end

end
