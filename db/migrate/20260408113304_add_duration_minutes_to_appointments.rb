class AddDurationMinutesToAppointments < ActiveRecord::Migration[8.1]
  def change
    add_column :appointments, :duration_minutes, :integer, default: 30
  end
end
