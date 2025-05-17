require "rails_helper"

RSpec.describe DataRetentionJob, type: :job do
  let(:tenant) { create(:tenant) }
  let(:provider) { create(:provider, tenant: tenant) }
  let(:patient) { create(:patient, tenant: tenant) }

  describe "#perform" do
    it "purges completed appointments older than 7 years" do
      old_appt = create(:appointment, tenant: tenant, provider: provider, patient: patient,
        status: :complete, starts_at: 8.years.ago)
      recent_appt = create(:appointment, tenant: tenant, provider: provider, patient: patient,
        status: :complete, starts_at: 6.years.ago)

      described_class.perform_now

      expect(Appointment.exists?(old_appt.id)).to eq(false)
      expect(Appointment.exists?(recent_appt.id)).to eq(true)
    end

    it "does not purge non-complete appointments" do
      old_scheduled = create(:appointment, tenant: tenant, provider: provider, patient: patient,
        status: :scheduled, starts_at: 8.years.ago)

      described_class.perform_now

      expect(Appointment.exists?(old_scheduled.id)).to eq(true)
    end

    it "preserves existing audit records when purging appointments" do
      old_appt = create(:appointment, tenant: tenant, provider: provider, patient: patient,
        status: :complete, starts_at: 8.years.ago)
      original_audits = Audited::Audit.where(auditable: old_appt).pluck(:id)

      described_class.perform_now

      expect(Audited::Audit.where(id: original_audits).count).to eq(original_audits.count)
    end

    it "respects tenant-specific retention period" do
      tenant.update!(data_retention_years: 3)
      old_appt = create(:appointment, tenant: tenant, provider: provider, patient: patient,
        status: :complete, starts_at: 4.years.ago)

      described_class.perform_now

      expect(Appointment.exists?(old_appt.id)).to eq(false)
    end
  end
end
