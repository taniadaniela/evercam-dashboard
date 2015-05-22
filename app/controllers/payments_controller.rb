class PaymentsController < ApplicationController
  before_filter :ensure_plan_in_cart_or_existing_subscriber
  before_filter :redirect_when_cart_empty, only: :new
  prepend_before_filter :ensure_card_exists
  include SessionsHelper
  include ApplicationHelper
  include CurrentCart
  include StripeCustomersHelper

  # This is the view checkout action
  def new
    @customer = retrieve_stripe_customer
    @total_charge = total_charge
    @pro_rated_add_ons_charge = pro_rated_add_ons_charge
    @add_ons_charge = add_ons_charge
    @cameras = load_user_cameras(true, false)
    @card = retrieve_credit_cards[:data][0]
  end

  def create
    @customer = retrieve_stripe_customer
    create_subscription unless @customer.has_active_subscription?
    change_plan if @customer.change_of_plan?
    create_charge if add_ons_in_cart?
    redirect_to billing_path(current_user.username), flash: { message: "We've successfully made those changes to your account!" }
  end

  def upgrade_downgrade_plan
    result = {success: true}
    begin
      product_params = build_line_item_params(params)
      @line_item = LineItem.new(product_params)
      @customer = retrieve_stripe_customer_without_cart(@line_item)
      @customer.change_plan

    rescue => error
      env["airbrake.error_id"] = notify_airbrake(error)
      Rails.logger.warn "Exception caught while upgrade/downgrade plan.\n"\
                              "Cause: #{error}\n" + error.backtrace.join("\n")
      result[:success] = false
      result[:message] = "Somethings gone wrong. We failed to change your plan."
    end
    render json: result
  end

  private

  def build_line_item_params params
    selector = ProductSelector.new(params[:plan_id])
    selector.product_params
  end

  def redirect_when_cart_empty
    if session[:cart].empty?
      redirect_to plans_path(current_user.username), flash: {message: "You have nothing to checkout."}
    end
  end

  def ensure_card_exists
    @customer = StripeCustomer.new(current_user.stripe_customer_id)
    unless @customer.valid_card?
      redirect_to plans_path(current_user.username), flash: { message: "You need to add a card first!" }
    end
  end

  def ensure_plan_in_cart_or_existing_subscriber
    unless @customer.has_active_subscription? || plan_in_cart?
      redirect_to plans_path(current_user.username), flash: { message: "You must select a plan." }
    end
  end

  def retrieve_stripe_customer
    StripeCustomer.new(current_user.stripe_customer_id, plan_in_cart)
  end

  def retrieve_stripe_customer_without_cart(product)
    StripeCustomer.new(current_user.stripe_customer_id, product)
  end

  def create_subscription
    @customer.create_subscription
    purge_plan_from_cart
    flash[:message] = "Plan created."
  rescue
    flash[:error] = "Something went wrong."
  end

  def change_plan
    @customer.change_plan
    purge_plan_from_cart
    flash[:message] = "Plan Changed."
  rescue
    flash[:error] = "Something went wrong."
  end

  # Make a new call to Stripe to refresh the subscription data
  def create_charge
    @customer = retrieve_stripe_customer
    @customer.create_charge(pro_rated_add_ons_charge, charge_description)
    insert_add_ons
    empty_cart
  rescue
    flash[:error] = "Something went wrong."
  end

  def pro_rate_percentage
    if @customer.current_plan && (Time.now.getutc.to_i - @customer.current_plan.created) >= 600
      month_period = @customer.current_subscription.current_period_end - @customer.current_subscription.current_period_start
      add_on_period = @customer.current_subscription.current_period_end - Time.now.getutc.to_i
      ((add_on_period.to_f / month_period.to_f) * 100)
    else
      100
    end
  end

  def pro_rated_add_ons_charge
    if add_ons_in_cart?
      ((add_ons_charge / 100) * pro_rate_percentage).to_i
    else
      nil
    end
  end

  def add_ons_charge
    amounts = add_ons_in_cart.map { |item| item.price }
    amounts.inject(0) {|sum, i|  sum + i }
  end

  # For an accurate subtotal of a mid term change, this method should also query Stripe for the pro rata change if the user switches plans.
  def total_charge
    pro_rated_add_ons_charge.present? ? pro_rated_add_ons_charge : calculate_total
  end

  def charge_description
    description = ''
    add_ons_in_cart.each_with_index do |item, index|
        description.concat(item.name)
        unless index.eql?(add_ons_in_cart.length - 1)
          description.concat(', ')
        else
          description.concat('.')
        end
      end
    description
  end

  private

  def insert_add_ons
    add_ons_in_cart.each_with_index do |item, index|
      begin
        AddOn.create(:user_id => current_user.id,
                      :add_ons_name => item.name,
                      :period => item.interval,
                      :add_ons_start_date => DateTime.now(),
                      :add_ons_end_date => calculateadd_ons_end_date(item),
                      :status => true,
                      :price => item.price)
      rescue => error
        @er = error
      end
    end
  end

  def calculateadd_ons_end_date add_on
    if add_on.interval.eql?('month')
      DateTime.now()+30.days
    else
      DateTime.now()+1.year
    end
  end

end

