class CreatePatients < ActiveRecord::Migration[8.1]
  def change
    create_table :patients do |t|
      t.references :tenant, null: false, foreign_key: true
      t.text :first_name_ciphertext
      t.text :last_name_ciphertext
      t.text :phone_ciphertext
      t.text :date_of_birth_ciphertext
      t.string :phone_bidx
      t.string :date_of_birth_bidx

      t.timestamps
    end

    add_index :patients, :phone_bidx
    add_index :patients, :date_of_birth_bidx
  end
end
