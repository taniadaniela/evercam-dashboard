Rails.configuration.stripe = {
  :publishable_key => ENV['STRIPE_PUBLISHABLE_KEY'],
  :secret_key      => ENV['STRIPE_SECRET_KEY']
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]

#Subscriber Block
StripeEvent.configure do |events|
  events.subscribe 'invoice.created' do |event|
    # Define subscriber behavior based on the event object
    event.class       #=> Stripe::Event
    event.type        #=> "charge.failed"
    event.data.object #=> #<Stripe::Charge:0x3fcb34c115f8>
    Rails.logger.info("Logging the #{event.id}")
    invoice = StripeInvoice.new(event.id)
    Rails.logger.info("Here is the event data:#{invoice.event_data}")
 end

  events.all do |event|
    # Handle all event types - logging, etc.
  end
end