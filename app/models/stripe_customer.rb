# Prefer that API calls are contained 
# For performance, when adding methods try avoid making a new API call to Stripe if the data you want is already contained in @stripe_customer
class StripeCustomer
  def initialize billing_id, plan_in_cart
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
    current_plan.id.eql?(@plan_in_cart.id) ? false : true
  rescue
    true
  end

  def current_plan
    @stripe_customer.subscriptions.first.plan
  end

  def valid_card?
    @stripe_customer.default_source.present?
  end

  def has_active_subscription?
    @stripe_customer.subscriptions.total_count > 0
  end

  def create_subscription
    stripe_customer.subscription.create(:plan => plan_in_cart.id)
  end

  def change_subscription
  end

  def create_charge(amount, description)
    Stripe::Charge.create(
      :customer    => @stripe_customer.id,
      :amount => amount,
      :description => description,
      :currency    => 'eur'
    )
  end











  def create_subscription

  end

  def stripe_subscriptions
    @subscriptions = Stripe::Customer.retrieve(@stripe_customer).subscriptions.all
  rescue
    false
  end

  def default_card?(card_id)
    @stripe_customer.default_source.eql?(card_id)
  end

  def retrieve_credit_cards
    Stripe::Customer.retrieve(current_user.billing_id).sources.all(:object => "card")
  end

  def has_credit_cards?
    stripe_customer = Stripe::Customer.retrieve(current_user.billing_id)
    stripe_customer.default_source.present?
  rescue
    false
  end

  def stripe_customer_without_current_cards?
    is_stripe_customer? and !has_credit_cards?
  end

  def stripe_customer_with_subscriptions?
    is_stripe_customer? and has_subscriptions?
  end

  def stripe_customer_without_subscriptions?
    is_stripe_customer? and !has_subscriptions?
  end

  def total_subscriptions_amount
    @subscriptions ||= Stripe::Customer.retrieve(current_user.billing_id).subscriptions.all
    amounts = @subscriptions.map { |s| s.plan.amount }
    total = amounts.inject(0) {|sum, i|  sum + i }
    number_to_currency(total / 100)
  end

  def stripe_plans
    @stripe_plans ||= Stripe::Plan.all
  end

end