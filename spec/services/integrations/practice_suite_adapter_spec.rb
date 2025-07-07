require "rails_helper"

RSpec.describe Integrations::PracticeSuiteAdapter do
  let(:tenant) { create(:tenant) }
  let(:integration) do
    create(:integration, tenant: tenant, adapter_type: "practice_suite", credentials: {
      "api_key" => "ps_test",
      "practice_id" => "practice_4242",
      "base_url" => "https://api.practicesuite.com/v2"
    })
  end

  subject(:adapter) { described_class.new(integration: integration) }

  let(:appointments_response) do
    {
      appointments: [
        {
          id: "ps-3300",
          appointmentTime: "2025-07-10T09:15:00-06:00",
          duration: 30,
          state: "Scheduled",
          patientInfo: {
            id: "ps-pat-1",
            firstName: "Diana",
            lastName: "Park",
            phone: "555-321-9876",
            birthDate: "1992-04-18"
          },
          providerInfo: {
            id: "ps-prov-1",
            firstName: "Marcus",
            lastName: "Reed",
            specialty: "MD"
          }
        }
      ]
    }
  end

  before do
    stub_request(:get, /api\.practicesuite\.com/)
      .to_return(status: 200, body: appointments_response.to_json, headers: { "Content-Type" => "application/json" })
  end

  describe "#fetch_appointments" do
    it "returns AppointmentDTOs" do
      dtos = adapter.fetch_appointments(date_range: Date.current..Date.current)
      expect(dtos.length).to eq(1)
    end

    it "maps PracticeSuite fields to DTO" do
      dto = adapter.fetch_appointments(date_range: Date.current..Date.current).first
      expect(dto.external_id).to eq("ps-3300")
      expect(dto.external_source).to eq("practice_suite")
      expect(dto.patient_first_name).to eq("Diana")
      expect(dto.patient_phone).to eq("5553219876")
      expect(dto.provider_last_name).to eq("Reed")
    end
  end
end
