class AddOnboardingStepToTenants < ActiveRecord::Migration[8.1]
  def change
    add_column :tenants, :onboarding_step, :integer, default: 0, null: false
  end
end
