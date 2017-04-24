class PaymentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :redirect_when_cart_empty, only: :new
  prepend_before_filter :ensure_card_exists, only: [:create, :new]
  prepend_before_filter :customer_id_exists, only: [:ensure_card_exists]
  skip_before_action :authenticate_user!, only: [:pay, :make_payment, :thank]
  layout "user-account"
  include SessionsHelper
  include ApplicationHelper
  include CurrentCart
  include StripeCustomersHelper
  include StripeInvoicesHelper
  require "stripe"

  def pay
    render layout: "bare-bones"
  end

  def thank
    render layout: "bare-bones"
  end

  def make_payment
    begin
      token = create_token(params)
      response = make_custom_payment(params, token)
      redirect_to thank_payment_path
    rescue => error
      flash[:error] = error.message
      redirect_to pay_path
    end
  end

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
    buy_subscription(params[:plan], params[:quantity].to_i)
    flash[:message] = 'You have succesfully added a new subscription!'
    render json: {result: true}
  end

  def upgrade_downgrade_plan
    result = {success: true}
    begin
      product_params = build_line_item_params(params)
      product_params[:quantity] = params[:quantity]
      @line_item = LineItem.new(product_params)
      @customer = retrieve_stripe_customer_without_cart(@line_item)
      @customer.change_plan
    rescue => error
      Rails.logger.warn "Exception caught while upgrade/downgrade plan.\n"\
                              "Cause: #{error}\n" + error.backtrace.join("\n")
      result[:success] = false
      result[:message] = "Somethings gone wrong. We failed to change your plan."
    end
    render json: result
  end

  private

  def create_token(params)
    Stripe::Token.create(
      :card => {
        :number => params["card-number"],
        :exp_month => params["expiry-month"],
        :exp_year => params["expiry-year"],
        :cvc => params["card-cvc"]
      },
    )
  end

  def make_custom_payment(params, token)
    amount = params[:amount].to_f * 100
    Stripe::Charge.create(
      :amount => amount.to_i,
      :currency => "eur",
      :source => token.id,
      :description => "Charge for #{params[:email]}"
    )
  end

  def buy_subscription(plan, quantity)
    selector = ProductSelector.new(plan)
    product_params = selector.product_params
    product_params[:quantity] = quantity
    storage = product_params[:storage]
    @line_item = LineItem.new(product_params)
    @customer = retrieve_stripe_customer_without_cart(@line_item)
    subscription = @customer.create_subscription
    save_licence(subscription, storage)
  end

  def save_licence(subscription, storage)
    licence = Licence.new(
      user_id: current_user.id,
      subscription_id: subscription.id,
      description: subscription.plan.name,
      total_cameras: subscription.quantity,
      storage: storage,
      amount: subscription.plan.amount,
      start_date: Time.at(subscription.current_period_start),
      end_date: Time.at(subscription.current_period_end),
      created_at: Time.at(subscription.start),
      auto_renew: !subscription.cancel_at_period_end,
      paid: true
    )
    licence.save
  end

  def update_subscription(plan, subscription_id, quantity)
    selector = ProductSelector.new(plan)
    product_params = selector.product_params
    product_params[:quantity] = quantity
    storage = product_params[:storage]
    @line_item = LineItem.new(product_params)
    @customer = retrieve_stripe_customer_without_cart(@line_item)
    subscription = @customer.update_subscription(subscription_id)
    update_licence(subscription, storage)
  end

  def update_licence(subscription, storage)
    licence = Licence.where(subscription_id: subscription.id).first
    licence.description = subscription.plan.name
    licence.total_cameras = subscription.quantity
    licence.storage = storage
    licence.amount = subscription.plan.amount
    licence.start_date = Time.at(subscription.current_period_start)
    licence.end_date = Time.at(subscription.current_period_end)
    licence.created_at = Time.at(subscription.start)
    licence.auto_renew = !subscription.cancel_at_period_end
    licence.paid = true
    licence.save
  end

  def cancel_subscription(subscription_id)
    @customer = StripeCustomer.new(current_user.stripe_customer_id)
    @customer.cancel_subscription(subscription_id)
    licence = Licence.where(subscription_id: subscription_id).first
    licence.cancel_licence = true
    licence.save
  end

  def build_line_item_params params
    selector = ProductSelector.new(params[:plan_id])
    selector.product_params
  end

  def redirect_when_cart_empty
    if session[:cart].nil?
      redirect_to billing_path(current_user.username), flash: {message: "You have nothing to checkout"}
    end
  end

  def ensure_card_exists
    @customer = StripeCustomer.new(current_user.stripe_customer_id)
    unless @customer.valid_card?
      redirect_to billing_path(current_user.username), flash: { message: "You need to add a card first!" }
    end
  end

  def customer_id_exists
    if current_user.stripe_customer_id.nil?
      redirect_to billing_path(current_user.username), flash: { message: "You need to add a card first!" }
    end
  end

  def ensure_plan_in_cart_or_existing_subscriber
    unless @customer.has_active_subscription? || plan_in_cart?
      redirect_to billing_path(current_user.username), flash: { message: "You must select a plan" }
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
    pro_rated_add_ons_charge.present? ? pro_rated_add_ons_charge + plan_cost : calculate_total
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

  def insert_add_ons
    add_ons_in_cart.each_with_index do |item, index|
      begin
        has_add_on = AddOn.where(user_id: current_user.id, exid: item.product_id)
        if has_add_on.blank?
          invoice_item = add_invoice_item(item.price, item.name, 1)
          invoice_item_id = invoice_item.id
        else
          invoice_item_id = has_add_on.first.invoice_item_id
          update_invoice_item(invoice_item_id, item.price, item.name, has_add_on.count + 1)
        end
        add_update_add_on(item, invoice_item_id)
      rescue => _error
      end
    end
  end

  def add_update_add_on(item, invoice_item_id)
    AddOn.create(user_id: current_user.id,
                 exid: item.product_id,
                 add_ons_name: item.name,
                 period: item.interval,
                 add_ons_start_date: DateTime.now(),
                 add_ons_end_date: calculateadd_ons_end_date(item),
                 status: true,
                 price: item.price,
                 invoice_item_id: invoice_item_id)
  end

  def calculateadd_ons_end_date add_on
    if add_on.interval.eql?('month')
      DateTime.now()+30.days
    else
      DateTime.now()+1.year
    end
  end

  def product_price(product_id)
    case product_id
    when "evercam-free"
      @prices.evercam_free
    when "evercam-free-annual"
      @prices.evercam_free_annual
    when "evercam-pro"
      @prices.evercam_pro
    when "evercam-pro-annual"
      @prices.evercam_pro_annual
    when "evercam-pro-plus"
      @prices.evercam_pro_plus
    when "evercam-pro-plus-annual"
      @prices.evercam_pro_plus_annual
    when "snapmail"
      @prices.snapmail
    when "snapmail-annual"
      @prices.snapmail_annual
    when "timelapse"
      @prices.timelapse
    when "timelapse-annual"
      @prices.timelapse_annual
    when "7-days-recording"
      @prices.seven_days_recording
    when "7-days-recording-annual"
      @prices.seven_days_recording_annual
    when "30-days-recording"
      @prices.thirty_days_recording
    when "30-days-recording-annual"
      @prices.thirty_days_recording_annual
    when "90-days-recording"
      @prices.ninety_days_recording
    when "90-days-recording-annual"
      @prices.ninety_days_recording_annual
    when "restream"
      @prices.restream
    when "restream-annual"
      @prices.restream_annual
    end
  end

end

