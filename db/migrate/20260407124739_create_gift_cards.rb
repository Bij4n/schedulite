class CreateGiftCards < ActiveRecord::Migration[8.1]
  def change
    create_table :gift_cards do |t|
      t.references :appointment, null: false, foreign_key: true
      t.references :tenant, null: false, foreign_key: true
      t.string :square_gan
      t.integer :amount_cents, null: false
      t.string :merchant_name
      t.string :merchant_url
      t.datetime :issued_at
      t.datetime :redeemed_at

      t.timestamps
    end
  end
end
