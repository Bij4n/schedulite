class AddNoShowFeeToTenants < ActiveRecord::Migration[8.1]
  def change
    add_column :tenants, :no_show_fee_cents, :integer
  end
end
