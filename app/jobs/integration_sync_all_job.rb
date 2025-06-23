class IntegrationSyncAllJob < ApplicationJob
  queue_as :default

  def perform
    Integration.find_each do |integration|
      next if integration.last_synced_at && integration.last_synced_at > 10.minutes.ago

      Integrations::SyncJob.perform_later(integration.id)
    end
  end
end
