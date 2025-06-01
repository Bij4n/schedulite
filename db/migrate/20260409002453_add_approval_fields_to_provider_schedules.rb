class AddApprovalFieldsToProviderSchedules < ActiveRecord::Migration[8.1]
  def change
    add_column :provider_schedules, :status, :string, default: "draft"
    add_reference :provider_schedules, :proposed_by, null: true, foreign_key: { to_table: :users }
    add_column :provider_schedules, :approved_at, :datetime
    add_column :provider_schedules, :notes, :text
  end
end
