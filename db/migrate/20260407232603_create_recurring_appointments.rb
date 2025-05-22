class CreateRecurringAppointments < ActiveRecord::Migration[8.1]
  def change
    create_table :recurring_appointments do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :provider, null: false, foreign_key: true
      t.references :patient, null: false, foreign_key: true
      t.string :recurrence_rule
      t.time :starts_at_time
      t.integer :duration_minutes
      t.boolean :active

      t.timestamps
    end
  end
end
