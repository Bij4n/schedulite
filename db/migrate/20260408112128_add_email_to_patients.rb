class AddEmailToPatients < ActiveRecord::Migration[8.1]
  def change
    add_column :patients, :email_ciphertext, :text
    add_column :patients, :email_bidx, :string
    add_index :patients, :email_bidx
  end
end
