class CreateIntegrations < ActiveRecord::Migration[8.1]
  def change
    create_table :integrations do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :adapter_type, null: false
      t.text :credentials_ciphertext
      t.datetime :last_synced_at
      t.string :status

      t.timestamps
    end
  end
end
