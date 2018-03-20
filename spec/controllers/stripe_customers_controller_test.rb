require 'spec_helper'

describe StripeCustomersControllerTest do
  let(:stripe_customers(:one)) {
    @stripe_customer
  }

  it "should get index" do
    pending
    get :index
    assert_response :success
    assert_not_nil assigns(:stripe_customers)
  end

  it "should get new" do
    pending
    get :new
    assert_response :success
  end

  it "should create stripe_customer" do
    pending
    assert_difference('StripeCustomer.count') do
      post :create, stripe_customer: {  }
    end

    assert_redirected_to stripe_customer_path(assigns(:stripe_customer))
  end

  it "should show stripe_customer" do
    pending
    get :show, id: @stripe_customer
    assert_response :success
  end

  it "should get edit" do
    pending
    get :edit, id: @stripe_customer
    assert_response :success
  end

  it "should update stripe_customer" do
    pending
    patch :update, id: @stripe_customer, stripe_customer: {  }
    assert_redirected_to stripe_customer_path(assigns(:stripe_customer))
  end

  it "should destroy stripe_customer" do
    pending
    assert_difference('StripeCustomer.count', -1) do
      delete :destroy, id: @stripe_customer
    end

    assert_redirected_to stripe_customers_path
  end
end
