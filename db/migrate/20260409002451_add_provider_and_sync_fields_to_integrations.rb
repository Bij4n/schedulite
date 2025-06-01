class AddProviderAndSyncFieldsToIntegrations < ActiveRecord::Migration[8.1]
  def change
    add_reference :integrations, :provider, null: true, foreign_key: true
    add_column :integrations, :sync_error, :text
    add_column :integrations, :sync_error_at, :datetime
  end
end
