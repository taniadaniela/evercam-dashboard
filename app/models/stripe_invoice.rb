# The invoice class should only invoked in response to webhooks.
# For midterm add-ons, and add ons created at the time of new subscription, use the charges controller. 

class StripeInvoice
  def initialize(stripe_event_id)
    @event_id = stripe_event_id
  end

  def process_invoice_items
    if valid_event_data? and user_billing?
      if user_has_snapmails?
        add_snapmail_invoice_items
      end
      if user_has_timelapses?
        add_timelapse_invoice_items
      end
    end 
  end

  private

  def valid_event_data?
    @event = Stripe::Event.retrieve(@event_id)
  rescue Stripe::InvalidRequestError => e
    Rails.logger.info e
    return false
  end

  def user_billing?
    @billing = Billing.where(:user_id => user_id).first
    return @billing.nil? ? false : @billing
  end

  def user_id
    User.find(:billing_id => stripe_customer_id).id 
    rescue
    nil     
  end

  def stripe_customer_id
    @event.data.object.customer
  rescue
    nil
  end

  def user_has_snapmails?
    number_of_snapmails > 0
  end

  def user_has_timelapses?
   number_of_timelapses > 0
  end

  def number_of_snapmails
    @snapmails = @billing.snapmail.present? ? @billing.snapmail : 0
  end

  def number_of_timelapses
    @timelapses = @billing.timelapse.present? ? @billing.timelapse : 0
  end

  def add_snapmail_invoice_items
    # add_invoice_item(AddOn.snapmail_price, 'Snapmail', @snapmails)
    add_invoice_item(1000, 'Snapmail', @snapmails)
  end

  def add_timelapse_invoice_items
    # add_invoice_item(AddOn.timelapse_price, 'Timelapse', @timelapses)
    add_invoice_item(3000, 'Timelapse', @timelapses)
  end

  def add_invoice_item(add_on_amount, add_on_description, add_on_quantity)
    Rails.logger.info("Logging: About to invoice Stripe")
    Stripe::InvoiceItem.create(
      :customer => stripe_customer_id,
      :amount => add_on_amount * add_on_quantity,
      :currency => "eur",
      :description => "#{add_on_description} x #{add_on_quantity}"
      )
    Rails.logger.info("Logging: Invoiced Stripe")
  rescue Stripe::InvalidRequestError => e
    Rails.logger.info("Logging: Failed to invoice Stripe#{e}")
  end 
end