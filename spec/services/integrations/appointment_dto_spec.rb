require "rails_helper"

RSpec.describe Integrations::AppointmentDTO do
  describe "initialization" do
    it "accepts required fields" do
      dto = described_class.new(
        external_id: "ext_123",
        external_source: "fhir:epic",
        patient_first_name: "Alex",
        patient_last_name: "Rivera",
        patient_phone: "5551234567",
        patient_dob: "1985-06-15",
        provider_first_name: "Sarah",
        provider_last_name: "Lee",
        starts_at: Time.current
      )

      expect(dto.external_id).to eq("ext_123")
      expect(dto.external_source).to eq("fhir:epic")
      expect(dto.patient_first_name).to eq("Alex")
      expect(dto.starts_at).to be_present
    end

    it "has optional fields with defaults" do
      dto = described_class.new(
        external_id: "ext_123",
        external_source: "fhir:epic",
        patient_first_name: "Alex",
        patient_last_name: "Rivera",
        patient_phone: "5551234567",
        starts_at: Time.current
      )

      expect(dto.ends_at).to be_nil
      expect(dto.provider_title).to be_nil
      expect(dto.status).to eq("scheduled")
    end
  end

  describe "validation" do
    it "requires external_id" do
      expect {
        described_class.new(external_source: "test", patient_first_name: "A", patient_last_name: "B", patient_phone: "555", starts_at: Time.current)
      }.to raise_error(ArgumentError)
    end

    it "requires starts_at" do
      expect {
        described_class.new(external_id: "1", external_source: "test", patient_first_name: "A", patient_last_name: "B", patient_phone: "555")
      }.to raise_error(ArgumentError)
    end
  end
end
