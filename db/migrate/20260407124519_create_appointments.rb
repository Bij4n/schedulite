class CreateAppointments < ActiveRecord::Migration[8.1]
  def change
    create_table :appointments do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :provider, null: false, foreign_key: true
      t.references :patient, null: false, foreign_key: true
      t.datetime :starts_at, null: false
      t.datetime :ends_at
      t.integer :status, null: false, default: 0
      t.text :notes_ciphertext
      t.string :external_id
      t.string :external_source
      t.string :signed_token
      t.integer :delay_minutes

      t.timestamps
    end

    add_index :appointments, :signed_token, unique: true
    add_index :appointments, [:external_source, :external_id]
    add_index :appointments, [:tenant_id, :starts_at]
  end
end
