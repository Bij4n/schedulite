class AddPrimaryProviderToPatients < ActiveRecord::Migration[8.1]
  def change
    add_reference :patients, :primary_provider, null: true, foreign_key: { to_table: :providers }
  end
end
