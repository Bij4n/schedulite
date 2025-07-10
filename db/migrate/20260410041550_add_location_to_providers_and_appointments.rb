class AddLocationToProvidersAndAppointments < ActiveRecord::Migration[8.1]
  def change
    add_reference :providers, :location, null: true, foreign_key: true
    add_reference :appointments, :location, null: true, foreign_key: true
  end
end
