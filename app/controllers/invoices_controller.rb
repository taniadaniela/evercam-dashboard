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
    begin
      if params[:invoice_id]
        @invoice = retrieve_customer_invoice(params[:invoice_id])
        @invoice_lines = retrieve_customer_invoice_lines(params[:invoice_id])
        if !@invoice || !@invoice_lines
          redirect_to invoices_path(current_user.username)
        end
      else
        redirect_to invoices_path(current_user.username)
      end
    rescue => error
      redirect_to invoices_path(current_user.username)
    end
  end
end