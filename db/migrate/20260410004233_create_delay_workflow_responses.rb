class CreateDelayWorkflowResponses < ActiveRecord::Migration[8.1]
  def change
    create_table :delay_workflow_responses do |t|
      t.references :delay_workflow, null: false, foreign_key: true
      t.references :appointment, null: false, foreign_key: true
      t.references :patient, null: false, foreign_key: true
      t.string :response, null: false, default: "no_response"
      t.datetime :responded_at
      t.boolean :gift_card_issued, default: false

      t.timestamps
    end
  end
end
