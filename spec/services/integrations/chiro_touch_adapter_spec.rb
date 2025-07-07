require "rails_helper"

RSpec.describe Integrations::ChiroTouchAdapter do
  let(:tenant) { create(:tenant) }
  let(:integration) do
    create(:integration, tenant: tenant, adapter_type: "chiro_touch", credentials: {
      "api_key" => "ct_test",
      "clinic_id" => "ct_clinic_99",
      "base_url" => "https://api.chirotouch.com/v1"
    })
  end

  subject(:adapter) { described_class.new(integration: integration) }

  let(:appointments_response) do
    {
      data: [
        {
          appointment_id: "ct-7771",
          start_time: "2025-07-09T10:00:00-05:00",
          end_time: "2025-07-09T10:30:00-05:00",
          status: "scheduled",
          patient: {
            patient_id: "pat-77",
            first_name: "Robert",
            last_name: "Brooks",
            primary_phone: "5559876543",
            dob: "1978-11-30"
          },
          provider: {
            provider_id: "dc-1",
            first_name: "Lisa",
            last_name: "Chen",
            credentials: "DC"
          }
        }
      ]
    }
  end

  before do
    stub_request(:get, /api\.chirotouch\.com/)
      .to_return(status: 200, body: appointments_response.to_json, headers: { "Content-Type" => "application/json" })
  end

  describe "#fetch_appointments" do
    it "returns AppointmentDTOs" do
      dtos = adapter.fetch_appointments(date_range: Date.current..Date.current)
      expect(dtos.length).to eq(1)
    end

    it "maps ChiroTouch fields to DTO" do
      dto = adapter.fetch_appointments(date_range: Date.current..Date.current).first
      expect(dto.external_id).to eq("ct-7771")
      expect(dto.external_source).to eq("chiro_touch")
      expect(dto.patient_first_name).to eq("Robert")
      expect(dto.patient_phone).to eq("5559876543")
      expect(dto.provider_last_name).to eq("Chen")
      expect(dto.provider_title).to eq("DC")
    end
  end
end
