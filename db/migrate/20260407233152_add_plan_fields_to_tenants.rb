class AddPlanFieldsToTenants < ActiveRecord::Migration[8.1]
  def change
    add_column :tenants, :plan, :string, default: "free"
    add_column :tenants, :trial_ends_at, :datetime
    add_column :tenants, :stripe_customer_id, :string
  end
end
