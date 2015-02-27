module ChargesHelper
  def stripe_customer?
    current_user.billing_id.present?
  end
end
