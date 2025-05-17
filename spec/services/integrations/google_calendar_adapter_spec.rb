require "rails_helper"

RSpec.describe Integrations::GoogleCalendarAdapter do
  let(:tenant) { create(:tenant) }
  let(:integration) do
    create(:integration, tenant: tenant, adapter_type: "google_calendar", credentials: {
      "access_token" => "ya29.test_access_token",
      "refresh_token" => "1//test_refresh_token",
      "calendar_id" => "primary",
      "client_id" => "test_client_id.apps.googleusercontent.com",
      "client_secret" => "test_client_secret"
    })
  end

  subject(:adapter) { described_class.new(integration: integration) }

  let(:events_response) do
    {
      items: [
        {
          id: "gcal_event_001",
          summary: "Alex Rivera - Consultation",
          start: { dateTime: "2025-05-17T14:30:00-04:00" },
          end: { dateTime: "2025-05-17T15:00:00-04:00" },
          description: "Phone: 555-123-4567",
          status: "confirmed",
          attendees: [
            { email: "alex@example.com", displayName: "Alex Rivera", responseStatus: "accepted" },
            { email: "dr.lee@practice.com", displayName: "Dr. Sarah Lee", responseStatus: "accepted", organizer: true }
          ]
        }
      ]
    }
  end

  before do
    stub_request(:get, /www\.googleapis\.com\/calendar\/v3\/calendars/)
      .to_return(status: 200, body: events_response.to_json, headers: { "Content-Type" => "application/json" })
  end

  describe "#fetch_appointments" do
    it "returns AppointmentDTOs" do
      dtos = adapter.fetch_appointments(date_range: Date.current..Date.current)
      expect(dtos).to be_an(Array)
      expect(dtos.length).to eq(1)
    end

    it "maps Google Calendar fields to DTO" do
      dto = adapter.fetch_appointments(date_range: Date.current..Date.current).first

      expect(dto.external_id).to eq("gcal_event_001")
      expect(dto.external_source).to eq("google_calendar")
      expect(dto.patient_first_name).to eq("Alex")
      expect(dto.patient_last_name).to eq("Rivera")
      expect(dto.patient_phone).to eq("5551234567")
      expect(dto.starts_at).to be_present
    end

    it "extracts phone from event description" do
      dto = adapter.fetch_appointments(date_range: Date.current..Date.current).first
      expect(dto.patient_phone).to eq("5551234567")
    end

    it "identifies the provider as the organizer" do
      dto = adapter.fetch_appointments(date_range: Date.current..Date.current).first
      expect(dto.provider_last_name).to eq("Lee")
    end
  end

  describe "#supports_webhooks?" do
    it "returns false" do
      expect(adapter.supports_webhooks?).to eq(false)
    end
  end
end
