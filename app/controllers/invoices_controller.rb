class InvoicesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :owns_data!
  before_filter :get_camares
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
      @subscription = current_subscription
      @invoice = retrieve_customer_invoice(params[:invoice_id])
      @invoice_lines = retrieve_customer_invoice_lines(params[:invoice_id])
      if !@invoice || !@invoice_lines
        redirect_to billing_path(current_user.username)
      end
    else
      redirect_to billing_path(current_user.username)
    end
  end

  def send_customer_invoice_email
    begin
      if params[:invoice_id]
        subscription = current_subscription
        period = subscription.interval
        invoice = retrieve_customer_invoice(params[:invoice_id])
        invoice_lines = retrieve_customer_invoice_lines(params[:invoice_id])
        if !invoice || !invoice_lines
          flash[:message] = "Unable to locate your invoice details in the system. Please refresh your view and try again."
        else
          StripeMailer.send_customer_invoice(invoice, invoice_lines, period, current_user.email).deliver_now
          flash[:message] = 'We’ve sent you an invoice email.'
        end
      else
        flash[:message] = "Unable to locate your invoice details in the system. Please refresh your view and try again."
      end
    rescue
      flash[:message] = "Unable to locate your invoice details in the system. Please refresh your view and try again."
    end
    redirect_to billing_path(current_user.username)
  end

  def create_pdf
    begin
      @subscription = current_subscription
      @invoice = retrieve_customer_invoice(params[:invoice_id])
      @invoice_lines = retrieve_customer_invoice_lines(params[:invoice_id])
      @html = render_to_string(:action => :create_pdf, :layout => "mailer.html.erb")
      pdf = WickedPdf.new.pdf_from_string(@html)
      send_data(pdf,
        :filename    => "#{@invoice[:id]}.pdf",
        :disposition => "attachment")
    rescue => _error
      flash[:message] = "Exception caught in create invoice pdf, Cause: #{_error.message}"
      redirect_to billing_path(current_user.username)
    end
  end

  def get_camares
    @cameras = load_user_cameras(true, false)
  end
end
