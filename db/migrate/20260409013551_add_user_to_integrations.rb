class AddUserToIntegrations < ActiveRecord::Migration[8.1]
  def change
    add_reference :integrations, :user, null: true, foreign_key: true
  end
end
