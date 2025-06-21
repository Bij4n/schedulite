class AddAddressToPatients < ActiveRecord::Migration[8.1]
  def change
    add_column :patients, :address_ciphertext, :text
    add_column :patients, :city, :string
    add_column :patients, :state, :string
    add_column :patients, :zip, :string
    add_column :patients, :latitude, :decimal
    add_column :patients, :longitude, :decimal
  end
end
