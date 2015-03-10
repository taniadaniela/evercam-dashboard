# The invoice class should only invoked in response to webhooks.
# For midterm add-ons, and add ons created at the time of new subscription, use the charges controller. 

class StripeInvoice
  def initialize(stripe_event_id)
    @event_id = stripe_event_id
  end

  def process_invoice_items
    if valid_event_data? and user_has_add_ons? and valid_user_billing?
      @event = valid_event_data?
      @user_add_ons = valid_user_billing?
      add_snapchat_invoice_items if number_of_snapchats > 0
      add_timelapse_invoice_items if number_of_timelapses? > 0
    end  
  end

  private

  def valid_event_data?
    Stripe::Event.retrieve(@event_id)
  rescue Stripe::InvalidRequestError => e
    Rails.logger.info e
    return false
  end

  def user_has_add_ons?
    number_of_snapchats > 0 or number_of_timelapses? > 0
  end

  def valid_user_billing?
    Billing.where(:user_id => user_id).first
  rescue
    return false
  end

  def user_id
    User.find(:billing_id => stripe_customer_id)
  end

  def stripe_customer_id
    @event.data.object.customer
  end

  def number_of_snapchats
    @snapchats = @user_add_ons.snapchats.present? ? @user_add_ons.snapchats : 0
  end

  def number_of_timelapses
    @timelapses = @user_add_ons.timelapses.present? ? @user_add_ons.timelapses : 0
  end

  def add_snapchat_invoice_items
    add_invoice_item(AddOn.snapchat_price, 'Snapchat', number_of_snapchats)
  end

  def add_timelapse_invoice_items
    add_invoice_item(AddOn.timelapse_price, 'Timelapse', number_of_timelapse)
  end

  def add_invoice_item(add_on_amount, add_on_description, add_on_quantity)
    Stripe::InvoiceItem.create(
      :customer => stripe_customer_id,
      :amount => add_on_amount
      :currency => "eur",
      :description => "#{add_on_description} x #{add_on_quantity}")
  rescue Stripe::InvalidRequestError => e
    Rails.logger.info e
  end 
end