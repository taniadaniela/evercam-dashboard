class InvoicesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :owns_data!
  layout "user-account"
  include SessionsHelper
  include ApplicationHelper
  include StripeCustomersHelper
  include StripeInvoicesHelper
  require "stripe"
  require "date"

  def index
    @invoices = retrieve_customer_invoices
  end

  def show
    if params[:invoice_id]
      @invoice = retrieve_customer_invoice(params[:invoice_id])
      @invoice_lines = retrieve_customer_invoice_lines(params[:invoice_id])
      if !@invoice || !@invoice_lines
        redirect_to invoices_path(current_user.username)
      end
    else
      redirect_to invoices_path(current_user.username)
    end
  end

  def send_customer_invoice_email
    begin
      if params[:invoice_id]
        invoice = retrieve_customer_invoice(params[:invoice_id])
        invoice_lines = retrieve_customer_invoice_lines(params[:invoice_id])
        if !invoice || !invoice_lines
          flash[:message] = "Unable to locate your invoice details in the system. Please refresh your view and try again."
        else
          StripeMailer.send_customer_invoice(invoice, invoice_lines, current_user.email).deliver_now
          flash[:message] = 'We’ve sent you an invoice email.'
        end
      else
        flash[:message] = "Unable to locate your invoice details in the system. Please refresh your view and try again."
      end
    rescue
      flash[:message] = "Unable to locate your invoice details in the system. Please refresh your view and try again."
    end
    redirect_to invoices_path(current_user.username)
  end

end