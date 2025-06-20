class CreateDelayWorkflows < ActiveRecord::Migration[8.1]
  def change
    create_table :delay_workflows do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :provider, null: false, foreign_key: true
      t.references :triggered_by, null: false, foreign_key: { to_table: :users }
      t.references :template, null: false, foreign_key: { to_table: :delay_workflow_templates }
      t.integer :delay_minutes, null: false
      t.string :status, null: false, default: "active"
      t.boolean :gift_card_enabled, default: false
      t.integer :affected_appointment_count, default: 0
      t.datetime :started_at

      t.timestamps
    end
  end
end
