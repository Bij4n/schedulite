class CreateProviderSchedules < ActiveRecord::Migration[8.1]
  def change
    create_table :provider_schedules do |t|
      t.references :provider, null: false, foreign_key: true
      t.integer :day_of_week
      t.time :start_time
      t.time :end_time
      t.integer :slot_duration_minutes

      t.timestamps
    end
  end
end
