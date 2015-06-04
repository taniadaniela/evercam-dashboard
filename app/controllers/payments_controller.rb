class PaymentsController < ApplicationController
  before_filter :ensure_plan_in_cart_or_existing_subscriber
  before_filter :redirect_when_cart_empty, only: :new
  prepend_before_filter :ensure_card_exists
  layout "user-account"
  include SessionsHelper
  include ApplicationHelper
  include CurrentCart
  include StripeCustomersHelper
  include StripeInvoicesHelper

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
      is_change_period = @customer.change_of_plan_period?
      @customer.change_plan
      if is_change_period
        set_prices
        @add_ons_arr = Array.new
        add_ons = AddOn.where(user_id: current_user.id)
        add_ons.each do |add_on|
          old_exid = add_on.exid
          add_on.period = @line_item.interval
          if @line_item.interval.eql?("month")
            add_on.add_ons_end_date = add_on.add_ons_start_date + 30.days
            add_on.exid = add_on.exid.gsub("-annual", "")
            add_on.add_ons_name = add_on.add_ons_name.gsub(" Annual", "")
            add_on.period = "month"
          else
            add_on.add_ons_end_date = add_on.add_ons_start_date + 1.year
            add_on.exid = "#{add_on.exid}-annual"
            add_on.add_ons_name = "#{add_on.add_ons_name} Annual"
            add_on.period = "year"
          end
          add_on.price = product_price(add_on.exid)
          has_created = @add_ons_arr.detect {|i| i.eql?(old_exid) } ? true : false
          unless has_created
            @add_ons_arr.push(old_exid)
            invoice_item = add_invoice_item(add_on.price.to_i, add_on.add_ons_name, add_ons.where(exid: old_exid).count)
            add_on.invoice_item_id = invoice_item.id
          end
          add_on.save
        end
      end
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
      redirect_to billing_path(current_user.username), flash: {message: "You have nothing to checkout"}
    end
  end

  def ensure_card_exists
    @customer = StripeCustomer.new(current_user.stripe_customer_id)
    unless @customer.valid_card?
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

  private

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

