require "rails_helper"

RSpec.describe IntegrationSyncAllJob, type: :job do
  let(:tenant) { create(:tenant) }

  describe "#perform" do
    it "enqueues sync jobs for integrations that need syncing" do
      integration = create(:integration, tenant: tenant, last_synced_at: 1.hour.ago)

      expect {
        described_class.perform_now
      }.to have_enqueued_job(Integrations::SyncJob).with(integration.id)
    end

    it "skips recently synced integrations" do
      create(:integration, tenant: tenant, last_synced_at: 5.minutes.ago)

      expect {
        described_class.perform_now
      }.not_to have_enqueued_job(Integrations::SyncJob)
    end

    it "syncs integrations that have never been synced" do
      integration = create(:integration, tenant: tenant, last_synced_at: nil)

      expect {
        described_class.perform_now
      }.to have_enqueued_job(Integrations::SyncJob).with(integration.id)
    end
  end
end
