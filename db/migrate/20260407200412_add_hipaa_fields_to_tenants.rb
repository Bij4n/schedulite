class AddHipaaFieldsToTenants < ActiveRecord::Migration[8.1]
  def change
    add_column :tenants, :data_retention_years, :integer, default: 7
    add_column :tenants, :baa_uploaded_at, :datetime
  end
end
