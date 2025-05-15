class CreateGiftCardSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :gift_card_settings do |t|
      t.references :tenant, null: false, foreign_key: true
      t.integer :delay_threshold_minutes
      t.integer :amount_cents
      t.string :merchant_name
      t.string :merchant_url

      t.timestamps
    end
  end
end
