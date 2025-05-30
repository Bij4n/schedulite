class CreateNoShowCharges < ActiveRecord::Migration[8.1]
  def change
    create_table :no_show_charges do |t|
      t.references :appointment, null: false, foreign_key: true
      t.references :patient, null: false, foreign_key: true
      t.references :tenant, null: false, foreign_key: true
      t.integer :amount_cents, null: false
      t.string :stripe_charge_id
      t.string :status, null: false, default: "pending"

      t.timestamps
    end
  end
end
