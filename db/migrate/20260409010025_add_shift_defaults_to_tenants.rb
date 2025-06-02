class AddShiftDefaultsToTenants < ActiveRecord::Migration[8.1]
  def change
    add_column :tenants, :default_shift_start, :string, default: "09:00"
    add_column :tenants, :default_shift_end, :string, default: "17:00"
    add_column :tenants, :default_break_minutes, :integer, default: 30
  end
end
