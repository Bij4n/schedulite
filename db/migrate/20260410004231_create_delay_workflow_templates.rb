class CreateDelayWorkflowTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :delay_workflow_templates do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :name, null: false
      t.text :message_body, null: false
      t.boolean :offer_reschedule, default: true
      t.boolean :offer_cancel, default: true
      t.boolean :offer_gift_card, default: false
      t.text :response_instructions

      t.timestamps
    end
  end
end
