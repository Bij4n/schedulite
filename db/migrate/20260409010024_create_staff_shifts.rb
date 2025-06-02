class CreateStaffShifts < ActiveRecord::Migration[8.1]
  def change
    create_table :staff_shifts do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :day_of_week, null: false
      t.string :start_time, null: false
      t.string :end_time, null: false
      t.integer :break_minutes, default: 30
      t.string :status, null: false, default: "proposed"

      t.timestamps
    end
  end
end
