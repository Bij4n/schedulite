class CreateTimeOffRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :time_off_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :approved_by, null: true, foreign_key: { to_table: :users }
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.string :request_type, null: false, default: "pto"
      t.text :reason
      t.string :status, null: false, default: "pending"
      t.datetime :responded_at

      t.timestamps
    end
  end
end
