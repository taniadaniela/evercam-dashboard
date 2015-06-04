module StripeInvoicesHelper
  def retrieve_customer_invoices
    if is_stripe_customer?
      Stripe::Invoice.all(:customer => current_user.stripe_customer_id, :limit => 10)
    else
      false
    end
  rescue
    false
  end

  def retrieve_recent_customer_invoices(limit)
    if is_stripe_customer?
      Stripe::Invoice.all(:customer => current_user.stripe_customer_id, :limit => limit)
    else
      false
    end
  rescue
    false
  end

  def retrieve_customer_next_charge
    if is_stripe_customer?
      Stripe::Invoice.upcoming(:customer => current_user.stripe_customer_id)
    else
      false
    end
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

  def add_invoice_item(add_on_amount, add_on_description, add_on_quantity)
    invoice_item = Stripe::InvoiceItem.create(
      :customer => current_user.stripe_customer_id,
      :amount => add_on_amount * add_on_quantity,
      :currency => "eur",
      :description => "#{add_on_description} x #{add_on_quantity}"
    )
  rescue Stripe::InvalidRequestError => e
    Rails.logger.info e
  end

  def update_invoice_item(invoice_item_id, add_on_amount, add_on_description, add_on_quantity)
    invoice_item = Stripe::InvoiceItem.retrieve(invoice_item_id)
    invoice_item.amount = add_on_amount * add_on_quantity
    invoice_item.description = "#{add_on_description} x #{add_on_quantity}"
    invoice_item.save
  rescue Stripe::InvalidRequestError => e
    Rails.logger.info e
  end

  def delete_invoice_item(invoice_item_id, add_on_amount, add_on_description)
    invoice_item = Stripe::InvoiceItem.retrieve(invoice_item_id)
    add_on_quantity = invoice_item.amount / add_on_amount
    if add_on_quantity > 1
      add_on_quantity -= 1
      invoice_item.amount = add_on_amount * add_on_quantity
      invoice_item.description = "#{add_on_description} x #{add_on_quantity}"
      invoice_item.save
    else
      invoice_item.delete
    end
  end
end