# Refactoring this gradually into the StripeCustomer class: prefer not to include helpers which call an API or the db
module StripeCustomersHelper
  def retrieve_stripe_customer
    @stripe_customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)
  rescue
    false
  end

  def retrieve_stripe_subscriptions
    @subscriptions = Stripe::Customer.retrieve(current_user.stripe_customer_id).subscriptions.all
  rescue
    false
  end

  def retrieve_customer_billing_history
    if is_stripe_customer?
      Stripe::Charge.all(:customer => current_user.stripe_customer_id, :limit => 10)
    else
      false
    end
  rescue
    false
  end

  def retrieve_customer_plan(invoice_id)
    invoice_items = Stripe::Invoice.retrieve(invoice_id).lines.all
    @description = ""
    invoice_items.each do |item|
      @description = item.description.blank? ? item.plan.id : item.description
    end
    @description
  rescue
    ""
  end

  def has_subscriptions?
    @stripe_customer ||= Stripe::Customer.retrieve(current_user.stripe_customer_id)
    @stripe_customer.subscriptions.total_count > 0
  end

  def default_card? card_id
    stripe_customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)
    stripe_customer.default_source.eql?(card_id)
  end

  def retrieve_credit_cards
    Stripe::Customer.retrieve(current_user.stripe_customer_id).sources.all(:object => "card")
  end

  def has_credit_cards?
    if is_stripe_customer?
      stripe_customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)
      stripe_customer.default_source.present?
    else
      false
    end
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
    @subscriptions ||= Stripe::Customer.retrieve(current_user.stripe_customer_id).subscriptions.all
    amounts = @subscriptions.map { |s| s.plan.amount }
    total = amounts.inject(0) {|sum, i|  sum + i }
    number_to_currency(total / 100)
  end

  def stripe_plans
    @stripe_plans ||= Stripe::Plan.all
  end

  def add_random_string_add_on(product_id)
    product_id = product_id.downcase.gsub(' ','')
    chars = [('a'..'z'), (0..9)].flat_map { |i| i.to_a }
    random_string = (0...3).map { chars[rand(chars.length)] }.join
    "#{product_id}-#{random_string}"
  end
end
