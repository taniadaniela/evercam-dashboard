module SubscriptionsHelper
  def has_subscription?
    @subscription.present?
  end
  def cart_empty?
    session[:cart].empty?
  end
end
