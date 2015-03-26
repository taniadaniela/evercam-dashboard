module SubscriptionsHelper
  def has_subscription?
    @subscription.present?
  end
end
