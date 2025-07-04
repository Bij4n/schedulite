class AddBillingFieldsToTenants < ActiveRecord::Migration[8.1]
  def change
    add_column :tenants, :stripe_subscription_id, :string
    add_column :tenants, :stripe_price_id, :string
    add_column :tenants, :billing_period_end, :datetime
  end
end
