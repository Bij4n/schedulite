require "rails_helper"

RSpec.describe Integrations::JaneAppAdapter do
  let(:tenant) { create(:tenant) }
  let(:integration) do
    create(:integration, tenant: tenant, adapter_type: "jane_app", credentials: {
      "api_key" => "jane_test_key",
      "clinic_id" => "clinic_123",
      "base_url" => "https://api.jane.app/v2"
    })
  end

  subject(:adapter) { described_class.new(integration: integration) }

  let(:appointments_response) do
    {
      appointments: [
        {
          id: "jane-appt-001",
          start_at: "2025-05-19T14:30:00-04:00",
          end_at: "2025-05-19T15:00:00-04:00",
          state: "booked",
          patient: {
            id: "pat-100",
            first_name: "Alex",
            last_name: "Rivera",
            phone: "555-123-4567",
            date_of_birth: "1985-06-15"
          },
          practitioner: {
            id: "prac-100",
            first_name: "Sarah",
            last_name: "Lee",
            title: "DPT"
          }
        }
      ],
      meta: { total: 1, page: 1 }
    }
  end

  before do
    stub_request(:get, /api\.jane\.app\/v2\/appointments/)
      .to_return(status: 200, body: appointments_response.to_json, headers: { "Content-Type" => "application/json" })
  end

  describe "#fetch_appointments" do
    it "returns AppointmentDTOs" do
      dtos = adapter.fetch_appointments(date_range: Date.current..Date.current)
      expect(dtos.length).to eq(1)
    end

    it "maps Jane App fields to DTO" do
      dto = adapter.fetch_appointments(date_range: Date.current..Date.current).first
      expect(dto.external_id).to eq("jane-appt-001")
      expect(dto.external_source).to eq("jane_app")
      expect(dto.patient_first_name).to eq("Alex")
      expect(dto.patient_last_name).to eq("Rivera")
      expect(dto.patient_phone).to eq("5551234567")
      expect(dto.provider_last_name).to eq("Lee")
      expect(dto.provider_title).to eq("DPT")
    end

    it "maps Jane state to internal status" do
      dto = adapter.fetch_appointments(date_range: Date.current..Date.current).first
      expect(dto.status).to eq("scheduled")
    end
  end

  describe "#supports_webhooks?" do
    it "returns false" do
      expect(adapter.supports_webhooks?).to eq(false)
    end
  end
end
