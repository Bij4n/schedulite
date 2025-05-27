class AddLunchBreakToTenants < ActiveRecord::Migration[8.1]
  def change
    add_column :tenants, :lunch_start, :string
    add_column :tenants, :lunch_end, :string
  end
end
