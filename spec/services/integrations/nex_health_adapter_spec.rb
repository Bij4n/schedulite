require "rails_helper"

RSpec.describe Integrations::NexHealthAdapter do
  let(:tenant) { create(:tenant) }
  let(:integration) do
    create(:integration, tenant: tenant, adapter_type: "nex_health", credentials: {
      "api_key" => "nh_test_key",
      "subdomain" => "sunrisedental",
      "location_id" => "loc_456"
    })
  end

  subject(:adapter) { described_class.new(integration: integration) }

  let(:appointments_response) do
    {
      data: [
        {
          id: 7001,
          start_time: "2025-05-19T14:00:00-04:00",
          end_time: "2025-05-19T14:30:00-04:00",
          status: "confirmed",
          patient: { id: 3001, first_name: "Casey", last_name: "Brooks", bio: { phone_number: "555-444-5555", date_of_birth: "1990-07-04" } },
          provider: { id: 2001, first_name: "Sarah", last_name: "Lee", suffix: "DDS" }
        }
      ],
      meta: { total: 1 }
    }
  end

  before do
    stub_request(:get, /nexhealth\.com\/api\/v1\/appointments/)
      .to_return(status: 200, body: appointments_response.to_json, headers: { "Content-Type" => "application/json" })
  end

  describe "#fetch_appointments" do
    it "returns AppointmentDTOs" do
      dtos = adapter.fetch_appointments(date_range: Date.current..Date.current)
      expect(dtos.length).to eq(1)
    end

    it "maps NexHealth fields to DTO" do
      dto = adapter.fetch_appointments(date_range: Date.current..Date.current).first
      expect(dto.external_id).to eq("7001")
      expect(dto.external_source).to eq("nex_health")
      expect(dto.patient_first_name).to eq("Casey")
      expect(dto.patient_phone).to eq("5554445555")
      expect(dto.provider_last_name).to eq("Lee")
      expect(dto.provider_title).to eq("DDS")
    end
  end

  describe "#supports_webhooks?" do
    it "returns true" do
      expect(adapter.supports_webhooks?).to eq(true)
    end
  end
end
