# Prefer that API calls are contained here
class StripeCustomer
  def initialize
    @stripe_customer = retrieve_stripe_customer
    logger.info("Logging Stripe Customer #{@stripe_customer}")
  end

  def retrieve_stripe_customer
    Stripe::Customer.retrieve(current_user.billing_id)
  rescue
    nil
  end

  def valid_card?
    @stripe_customer.default_source.present?
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