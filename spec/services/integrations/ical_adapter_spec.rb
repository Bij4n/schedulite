require "rails_helper"

RSpec.describe Integrations::IcalAdapter do
  let(:tenant) { create(:tenant) }
  let(:integration) do
    create(:integration, tenant: tenant, adapter_type: "ical", credentials: {
      "feed_url" => "https://calendar.example.com/feed.ics",
      "provider_name" => "Dr. Sarah Lee"
    })
  end

  subject(:adapter) { described_class.new(integration: integration) }

  let(:ical_content) do
    <<~ICS
      BEGIN:VCALENDAR
      VERSION:2.0
      BEGIN:VEVENT
      UID:event-001@example.com
      DTSTART:20250520T143000
      DTEND:20250520T150000
      SUMMARY:Alex Rivera - Consultation
      DESCRIPTION:Phone: 555-123-4567
      STATUS:CONFIRMED
      END:VEVENT
      BEGIN:VEVENT
      UID:event-002@example.com
      DTSTART:20250520T153000
      DTEND:20250520T160000
      SUMMARY:Jordan Kim - Follow-up
      DESCRIPTION:Phone: 555-987-6543
      STATUS:CONFIRMED
      END:VEVENT
      END:VCALENDAR
    ICS
  end

  before do
    stub_request(:get, "https://calendar.example.com/feed.ics")
      .to_return(status: 200, body: ical_content)
  end

  describe "#fetch_appointments" do
    it "returns AppointmentDTOs" do
      dtos = adapter.fetch_appointments(date_range: Date.new(2025, 5, 20)..Date.new(2025, 5, 20))
      expect(dtos.length).to eq(2)
    end

    it "parses event fields" do
      dtos = adapter.fetch_appointments(date_range: Date.new(2025, 5, 20)..Date.new(2025, 5, 20))
      dto = dtos.first

      expect(dto.external_id).to eq("event-001@example.com")
      expect(dto.external_source).to eq("ical")
      expect(dto.patient_first_name).to eq("Alex")
      expect(dto.patient_last_name).to eq("Rivera")
      expect(dto.patient_phone).to eq("5551234567")
    end

    it "uses configured provider name" do
      dtos = adapter.fetch_appointments(date_range: Date.new(2025, 5, 20)..Date.new(2025, 5, 20))
      expect(dtos.first.provider_last_name).to eq("Lee")
    end
  end

  describe "#supports_webhooks?" do
    it "returns false" do
      expect(adapter.supports_webhooks?).to eq(false)
    end
  end
end
