class AddStripeFieldsToPatients < ActiveRecord::Migration[8.1]
  def change
    add_column :patients, :stripe_customer_id_ciphertext, :text
    add_column :patients, :stripe_payment_method_id_ciphertext, :text
    add_column :patients, :card_last4, :string
    add_column :patients, :card_brand, :string
  end
end
