require "rails_helper"

RSpec.describe Integrations::FHIRAdapter do
  let(:tenant) { create(:tenant) }
  let(:integration) do
    create(:integration, tenant: tenant, adapter_type: "fhir", credentials: {
      "base_url" => "https://fhir.epic.com/interconnect-fhir-oauth/api/FHIR/R4",
      "client_id" => "test_client_id",
      "access_token" => "test_access_token",
      "token_expires_at" => 1.hour.from_now.iso8601
    })
  end

  subject(:adapter) { described_class.new(integration: integration) }

  let(:fhir_appointment_bundle) do
    {
      resourceType: "Bundle",
      type: "searchset",
      entry: [
        {
          resource: {
            resourceType: "Appointment",
            id: "fhir-appt-001",
            status: "booked",
            start: "2026-04-07T14:30:00Z",
            end: "2026-04-07T15:00:00Z",
            participant: [
              {
                actor: { reference: "Patient/pat-001", display: "Rivera, Alex" },
                status: "accepted"
              },
              {
                actor: { reference: "Practitioner/prac-001", display: "Lee, Sarah MD" },
                status: "accepted"
              }
            ]
          }
        }
      ]
    }
  end

  let(:fhir_patient) do
    {
      resourceType: "Patient",
      id: "pat-001",
      name: [{ family: "Rivera", given: ["Alex"] }],
      telecom: [{ system: "phone", value: "555-123-4567", use: "mobile" }],
      birthDate: "1985-06-15"
    }
  end

  before do
    stub_request(:get, /Appointment/)
      .to_return(status: 200, body: fhir_appointment_bundle.to_json, headers: { "Content-Type" => "application/fhir+json" })

    stub_request(:get, /Patient\/pat-001/)
      .to_return(status: 200, body: fhir_patient.to_json, headers: { "Content-Type" => "application/fhir+json" })
  end

  describe "#fetch_appointments" do
    it "returns an array of AppointmentDTOs" do
      dtos = adapter.fetch_appointments(date_range: Date.current..Date.current)
      expect(dtos).to be_an(Array)
      expect(dtos.length).to eq(1)
    end

    it "maps FHIR fields to DTO" do
      dto = adapter.fetch_appointments(date_range: Date.current..Date.current).first

      expect(dto.external_id).to eq("fhir-appt-001")
      expect(dto.external_source).to eq("fhir")
      expect(dto.patient_first_name).to eq("Alex")
      expect(dto.patient_last_name).to eq("Rivera")
      expect(dto.patient_phone).to eq("5551234567")
      expect(dto.provider_last_name).to eq("Lee")
      expect(dto.starts_at).to be_present
    end

    it "sets external_source to fhir" do
      dto = adapter.fetch_appointments(date_range: Date.current..Date.current).first
      expect(dto.external_source).to eq("fhir")
    end
  end

  describe "#supports_webhooks?" do
    it "returns false" do
      expect(adapter.supports_webhooks?).to eq(false)
    end
  end
end
