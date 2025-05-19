require "rails_helper"

RSpec.describe Integrations::SimplePracticeAdapter do
  let(:tenant) { create(:tenant) }
  let(:integration) do
    create(:integration, tenant: tenant, adapter_type: "simple_practice", credentials: {
      "access_token" => "sp_test_token",
      "base_url" => "https://api.simplepractice.com/v1"
    })
  end

  subject(:adapter) { described_class.new(integration: integration) }

  let(:appointments_response) do
    {
      data: [
        {
          id: "sp-appt-001",
          attributes: {
            start_time: "2025-05-19T10:00:00-04:00",
            end_time: "2025-05-19T10:50:00-04:00",
            status: "confirmed"
          },
          relationships: {
            client: { data: { id: "client-200" } },
            practitioner: { data: { id: "prac-200" } }
          }
        }
      ]
    }
  end

  let(:client_response) do
    { data: { id: "client-200", attributes: { first_name: "Jordan", last_name: "Kim", phone_number: "555-987-6543", date_of_birth: "1992-03-22" } } }
  end

  let(:practitioner_response) do
    { data: { id: "prac-200", attributes: { first_name: "Michael", last_name: "Chen", credential: "PhD" } } }
  end

  before do
    stub_request(:get, /simplepractice\.com\/v1\/appointments/).to_return(status: 200, body: appointments_response.to_json, headers: { "Content-Type" => "application/json" })
    stub_request(:get, /simplepractice\.com\/v1\/clients\/client-200/).to_return(status: 200, body: client_response.to_json, headers: { "Content-Type" => "application/json" })
    stub_request(:get, /simplepractice\.com\/v1\/practitioners\/prac-200/).to_return(status: 200, body: practitioner_response.to_json, headers: { "Content-Type" => "application/json" })
  end

  describe "#fetch_appointments" do
    it "returns AppointmentDTOs" do
      dtos = adapter.fetch_appointments(date_range: Date.current..Date.current)
      expect(dtos.length).to eq(1)
    end

    it "maps SimplePractice fields to DTO" do
      dto = adapter.fetch_appointments(date_range: Date.current..Date.current).first
      expect(dto.external_id).to eq("sp-appt-001")
      expect(dto.external_source).to eq("simple_practice")
      expect(dto.patient_first_name).to eq("Jordan")
      expect(dto.patient_phone).to eq("5559876543")
      expect(dto.provider_last_name).to eq("Chen")
    end
  end

  describe "#supports_webhooks?" do
    it "returns false" do
      expect(adapter.supports_webhooks?).to eq(false)
    end
  end
end
