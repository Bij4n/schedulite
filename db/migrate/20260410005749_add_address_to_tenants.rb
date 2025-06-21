class AddAddressToTenants < ActiveRecord::Migration[8.1]
  def change
    add_column :tenants, :address, :string
    add_column :tenants, :city, :string
    add_column :tenants, :state, :string
    add_column :tenants, :zip, :string
    add_column :tenants, :latitude, :decimal
    add_column :tenants, :longitude, :decimal
  end
end
