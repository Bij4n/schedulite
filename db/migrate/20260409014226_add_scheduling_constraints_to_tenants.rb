class AddSchedulingConstraintsToTenants < ActiveRecord::Migration[8.1]
  def change
    add_column :tenants, :max_hours_per_week, :integer, default: 40
    add_column :tenants, :required_lunch_minutes, :integer, default: 30
  end
end
