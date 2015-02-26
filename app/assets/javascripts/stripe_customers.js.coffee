# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  Stripe.setPublishableKey('<%= STRIPE_PUBLISHABLE_KEY %>')
  stripe_customer.setupForm()

stripe_customer = 
  setupForm: ->
    console.log("I'm here")
    $('#new_stripe_customer').submit ->

      $('input[type=submit]').prop('disabled', true)
      # alert(this)
      # alert('I am blocking')
      stripe_customer.processCard()
      false
      # console.log(this)
      # console.log("I'm here")

  processCard: ->
    card = 
      number: $('#card-number').val()
      cvc: $('#card-code').val()
      exp_month: $('#card-month').val()
      exp_year: $('#card-year').val()
    Stripe.card.createToken(card, this.handleStripeResponse)
    # Stripe.card.createToken(card, alert('Here'))

  handleStripeResponse: (status, response) ->
    if status == 200
      alert(response.id)
    else
      alert(response.error.message)


