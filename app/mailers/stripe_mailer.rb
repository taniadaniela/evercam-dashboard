class StripeMailer < ActionMailer::Base
  default from: "support@evercam.io"
  default to: "support@evercam.io"

  def send_customer_invoice(invoice, invoice_lines, user_email)
    @invoice    = invoice
    @invoice_lines    = invoice_lines
    mail(to: user_email, subject: "Payment Invoice")
  end

end