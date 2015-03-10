class StripeInvoice

  def initialize(stripe_event_id)
    @event_id = stripe_event_id
  end

  def event_data
    Stripe::Event.retrieve(@event_id)
  end


  def update
    unless !user_bill
      cost = add_ons_cost
      # API Call to Stripe
    end
  end

  private

  # def event_data
  #   Stripe::Event.retrieve(@event_id)
  # end

  def add_ons_cost
    user_add_ons
    AddOn.snapchat_price * @number_of_snapchats + AddOn.timelapse.price * @number_of_timelapses
  end  

  def user_add_ons
    bill = user_bill
    @number_of_snapchats = bill.snapchats ? bill.snapchats : 0
    @number_of_timelapses = bill.timelapses ? bill.timelapses : 0
  end

  def user_bill
    begin
      Billing.where(:user_id => current_user.id)
    rescue
      return false
    end
  end

end