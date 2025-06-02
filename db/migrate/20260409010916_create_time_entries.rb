class CreateTimeEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :time_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :clock_in_at
      t.datetime :clock_out_at
      t.integer :break_minutes_taken
      t.string :status
      t.string :ip_address
      t.text :notes

      t.timestamps
    end
  end
end
