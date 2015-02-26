require 'test_helper'

class StripeCustomersControllerTest < ActionController::TestCase
  setup do
    @stripe_customer = stripe_customers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:stripe_customers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create stripe_customer" do
    assert_difference('StripeCustomer.count') do
      post :create, stripe_customer: {  }
    end

    assert_redirected_to stripe_customer_path(assigns(:stripe_customer))
  end

  test "should show stripe_customer" do
    get :show, id: @stripe_customer
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @stripe_customer
    assert_response :success
  end

  test "should update stripe_customer" do
    patch :update, id: @stripe_customer, stripe_customer: {  }
    assert_redirected_to stripe_customer_path(assigns(:stripe_customer))
  end

  test "should destroy stripe_customer" do
    assert_difference('StripeCustomer.count', -1) do
      delete :destroy, id: @stripe_customer
    end

    assert_redirected_to stripe_customers_path
  end
end
