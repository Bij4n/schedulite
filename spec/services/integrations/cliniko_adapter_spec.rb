require "rails_helper"

RSpec.describe Integrations::ClinikoAdapter do
  let(:tenant) { create(:tenant) }
  let(:integration) do
    create(:integration, tenant: tenant, adapter_type: "cliniko", credentials: {
      "api_key" => "cliniko_key_us2",
      "shard" => "us2"
    })
  end

  subject(:adapter) { described_class.new(integration: integration) }

  let(:appointments_response) do
    {
      individual_appointments: [
        {
          id: 9001,
          starts_at: "2025-07-08T14:30:00Z",
          ends_at: "2025-07-08T15:00:00Z",
          cancelled_at: nil,
          patient_arrived_at: nil,
          patient: {
            id: 200,
            first_name: "Maria",
            last_name: "Santos",
            patient_phone_numbers: [{ number: "(555) 234-5678" }],
            date_of_birth: "1990-03-22"
          },
          practitioner: {
            id: 300,
            first_name: "James",
            last_name: "Wong",
            title: "Physiotherapist"
          }
        }
      ]
    }
  end

  before do
    stub_request(:get, /api\.us2\.cliniko\.com/)
      .to_return(status: 200, body: appointments_response.to_json, headers: { "Content-Type" => "application/json" })
  end

  describe "#fetch_appointments" do
    it "returns AppointmentDTOs" do
      dtos = adapter.fetch_appointments(date_range: Date.current..Date.current)
      expect(dtos.length).to eq(1)
    end

    it "maps Cliniko fields to DTO" do
      dto = adapter.fetch_appointments(date_range: Date.current..Date.current).first
      expect(dto.external_id).to eq("9001")
      expect(dto.external_source).to eq("cliniko")
      expect(dto.patient_first_name).to eq("Maria")
      expect(dto.patient_phone).to eq("5552345678")
      expect(dto.provider_last_name).to eq("Wong")
    end
  end

  describe "#supports_webhooks?" do
    it "returns true" do
      expect(adapter.supports_webhooks?).to be true
    end
  end
end
