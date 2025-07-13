class AddMagicLinkToPatients < ActiveRecord::Migration[8.1]
  def change
    add_column :patients, :magic_link_token, :string
    add_column :patients, :magic_link_expires_at, :datetime
    add_index :patients, :magic_link_token, unique: true
  end
end
