Rails.configuration.stripe = {
  :publishable_key => ENV['STRIPE_PUBLISHABLE_KEY'],
  :secret_key      => ENV['STRIPE_SECRET_KEY']
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]

Rails.logger.info("I'm outside the subscriber block")

#Subscriber Block
StripeEvent.configure do |events|
  events.subscribe 'invoiceitem.created' do |event|
    # Define subscriber behavior based on the event object
    event.class       #=> Stripe::Event
    event.type        #=> "charge.failed"
    event.data.object #=> #<Stripe::Charge:0x3fcb34c115f8>
    Rails.logger.info("Logging the #{event.class}")
  end

  events.all do |event|
    # Handle all event types - logging, etc.
  end
end