module StripeInvoicesHelper
  def retrieve_customer_invoices
    Stripe::Invoice.all(:customer => current_user.stripe_customer_id, :limit => 100)
  rescue
    false
  end

  def retrieve_customer_invoice(invoice_id)
    Stripe::Invoice.retrieve(invoice_id)
  rescue
    false
  end

  def retrieve_customer_invoice_lines(invoice_id)
    Stripe::Invoice.retrieve(invoice_id).lines.all
  rescue
    false
  end
end