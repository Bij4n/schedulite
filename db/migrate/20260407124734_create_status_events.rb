class CreateStatusEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :status_events do |t|
      t.references :appointment, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.string :from_status
      t.string :to_status, null: false
      t.integer :delay_minutes
      t.text :note

      t.timestamps
    end
  end
end
