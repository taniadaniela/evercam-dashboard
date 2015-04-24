# For performance, when adding methods try avoid making a new API call to Stripe
# if the data you want is already contained in @stripe_customer
class StripeCustomer
  def initialize billing_id, plan_in_cart=nil
    @plan_in_cart = plan_in_cart
    @billing_id = billing_id
    @stripe_customer = retrieve_stripe_customer
  end

  def retrieve_stripe_customer
    Stripe::Customer.retrieve(@billing_id)
  rescue Stripe::InvalidRequestError => e
    Rails.logger.info e
    nil
  end

  def change_of_plan?
    current_plan.id.eql?(@plan_in_cart.product_id) ? false : true
  rescue
    false
  end

  def current_plan
    @stripe_customer.subscriptions.first.plan
  rescue
    false
  end

  def current_subscription
    @stripe_customer.subscriptions.first
  end

  def subscription_id
    @stripe_customer.subscriptions.first.id
  end

  def valid_card?
    @stripe_customer.default_source.present?
  end

  def has_active_subscription?
    @stripe_customer.subscriptions.total_count > 0
  end

  def create_subscription
    @stripe_customer.subscriptions.create(:plan => @plan_in_cart.product_id)
  end

  def change_plan
    subscription = @stripe_customer.subscriptions.retrieve(subscription_id)
    subscription.plan = @plan_in_cart.product_id
    subscription.save
  end

  def create_charge(amount, description)
    Stripe::Charge.create(
      :customer    => @stripe_customer.id,
      :amount => amount,
      :description => description,
      :currency    => 'eur'
    )
  end
end