require "rails_helper"

RSpec.describe Integrations::AcuityAdapter do
  let(:tenant) { create(:tenant) }
  let(:integration) do
    create(:integration, tenant: tenant, adapter_type: "acuity", credentials: {
      "user_id" => "12345",
      "api_key" => "acuity_test_key",
      "webhook_secret" => "acuity_webhook_secret"
    })
  end

  subject(:adapter) { described_class.new(integration: integration) }

  let(:appointments_response) do
    [
      {
        id: 98765,
        firstName: "Sam",
        lastName: "Okafor",
        phone: "555-111-2222",
        email: "sam@example.com",
        datetime: "2025-05-19T13:30:00-0400",
        endTime: "2025-05-19T14:00:00-0400",
        calendar: "Dr. Sarah Lee",
        canceled: false
      }
    ]
  end

  before do
    stub_request(:get, /acuityscheduling\.com\/api\/v1\/appointments/)
      .to_return(status: 200, body: appointments_response.to_json, headers: { "Content-Type" => "application/json" })
  end

  describe "#fetch_appointments" do
    it "returns AppointmentDTOs" do
      dtos = adapter.fetch_appointments(date_range: Date.current..Date.current)
      expect(dtos.length).to eq(1)
    end

    it "maps Acuity fields to DTO" do
      dto = adapter.fetch_appointments(date_range: Date.current..Date.current).first
      expect(dto.external_id).to eq("98765")
      expect(dto.external_source).to eq("acuity")
      expect(dto.patient_first_name).to eq("Sam")
      expect(dto.patient_last_name).to eq("Okafor")
      expect(dto.patient_phone).to eq("5551112222")
    end
  end

  describe "#supports_webhooks?" do
    it "returns true" do
      expect(adapter.supports_webhooks?).to eq(true)
    end
  end

  describe "#parse_webhook" do
    let(:payload) do
      { id: 98766, action: "scheduled", calendarID: 1, appointmentTypeID: 2 }.to_json
    end

    before do
      stub_request(:get, /acuityscheduling\.com\/api\/v1\/appointments\/98766/)
        .to_return(status: 200, body: {
          id: 98766, firstName: "Taylor", lastName: "Nguyen", phone: "555-333-4444",
          datetime: "2025-05-20T09:00:00-0400", endTime: "2025-05-20T09:30:00-0400",
          calendar: "NP Priya Patel", canceled: false
        }.to_json, headers: { "Content-Type" => "application/json" })
    end

    it "fetches full appointment and returns DTO" do
      dto = adapter.parse_webhook(payload)
      expect(dto.external_id).to eq("98766")
      expect(dto.patient_first_name).to eq("Taylor")
    end
  end
end
