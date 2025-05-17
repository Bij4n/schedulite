class DataRetentionJob < ApplicationJob
  queue_as :low

  def perform
    Tenant.find_each do |tenant|
      ActsAsTenant.with_tenant(tenant) do
        retention_years = tenant.data_retention_years || 7
        cutoff = retention_years.years.ago

        Appointment
          .where(status: :complete)
          .where(starts_at: ...cutoff)
          .find_each(&:destroy)
      end
    end
  end
end
