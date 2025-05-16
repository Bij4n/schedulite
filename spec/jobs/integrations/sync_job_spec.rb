require "rails_helper"

RSpec.describe Integrations::SyncJob, type: :job do
  let(:tenant) { create(:tenant) }
  let(:integration) { create(:integration, tenant: tenant, adapter_type: "fhir") }

  let(:dto) do
    Integrations::AppointmentDTO.new(
      external_id: "ext_456",
      external_source: "fhir:epic",
      patient_first_name: "Alex",
      patient_last_name: "Rivera",
      patient_phone: "5551234567",
      patient_dob: "1985-06-15",
      provider_first_name: "Sarah",
      provider_last_name: "Lee",
      starts_at: Time.current.change(hour: 14, min: 30)
    )
  end

  let(:adapter) { instance_double(Integrations::Adapter) }

  before do
    allow(Integrations::AdapterFactory).to receive(:build).and_return(adapter)
    allow(adapter).to receive(:fetch_appointments).and_return([dto])
  end

  describe "#perform" do
    it "creates a new appointment from DTO" do
      expect {
        described_class.perform_now(integration.id)
      }.to change(Appointment, :count).by(1)

      appt = Appointment.last
      expect(appt.external_id).to eq("ext_456")
      expect(appt.external_source).to eq("fhir:epic")
      expect(appt.patient.first_name).to eq("Alex")
      expect(appt.provider.last_name).to eq("Lee")
    end

    it "creates a new patient if not found by phone" do
      expect {
        described_class.perform_now(integration.id)
      }.to change(Patient, :count).by(1)
    end

    it "reuses existing patient matched by phone" do
      create(:patient, tenant: tenant, first_name: "Alex", last_name: "Rivera", phone: "5551234567")

      expect {
        described_class.perform_now(integration.id)
      }.not_to change(Patient, :count)
    end

    it "is idempotent — running twice does not duplicate" do
      described_class.perform_now(integration.id)
      expect {
        described_class.perform_now(integration.id)
      }.not_to change(Appointment, :count)
    end

    it "updates last_synced_at on the integration" do
      described_class.perform_now(integration.id)
      expect(integration.reload.last_synced_at).to be_within(2.seconds).of(Time.current)
    end

    it "creates a provider if not found" do
      expect {
        described_class.perform_now(integration.id)
      }.to change(Provider, :count).by(1)
    end

    it "reuses existing provider matched by name" do
      create(:provider, tenant: tenant, first_name: "Sarah", last_name: "Lee")

      expect {
        described_class.perform_now(integration.id)
      }.not_to change(Provider, :count)
    end
  end
end
