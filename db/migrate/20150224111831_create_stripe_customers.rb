class CreateStripeCustomers < ActiveRecord::Migration
  def change
    create_table :stripe_customers do |t|
      #t.string :stripe_billing_id
      #Don't run this yet - not sure if I need a model, the billing_id is already saved on the user at the moment so that might be the best place to keep it.
      t.timestamps null: false
    end
  end
end
