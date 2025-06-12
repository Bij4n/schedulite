class AddLunchBreakToProviderSchedules < ActiveRecord::Migration[8.1]
  def change
    add_column :provider_schedules, :lunch_start, :string
    add_column :provider_schedules, :lunch_end, :string
  end
end
