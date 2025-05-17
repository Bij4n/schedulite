require "rails_helper"

RSpec.describe Integrations::CalendlyAdapter do
  let(:tenant) { create(:tenant) }
  let(:integration) do
    create(:integration, tenant: tenant, adapter_type: "calendly", credentials: {
      "api_key" => "test_calendly_key",
      "webhook_signing_key" => "whsec_test_signing_key",
      "organization_uri" => "https://api.calendly.com/organizations/ORG123"
    })
  end

  subject(:adapter) { described_class.new(integration: integration) }

  describe "#supports_webhooks?" do
    it "returns true" do
      expect(adapter.supports_webhooks?).to eq(true)
    end
  end

  describe "#fetch_appointments" do
    let(:calendly_events_response) do
      {
        collection: [
          {
            uri: "https://api.calendly.com/scheduled_events/EVT001",
            name: "30 Minute Consultation",
            status: "active",
            start_time: "2025-05-17T14:30:00.000000Z",
            end_time: "2025-05-17T15:00:00.000000Z",
            event_memberships: [
              { user_name: "Dr. Sarah Lee" }
            ]
          }
        ],
        pagination: { count: 1, next_page: nil }
      }
    end

    let(:invitee_response) do
      {
        collection: [
          {
            uri: "https://api.calendly.com/scheduled_events/EVT001/invitees/INV001",
            name: "Alex Rivera",
            email: "alex@example.com",
            text_reminder_number: "+15551234567",
            status: "active"
          }
        ]
      }
    end

    before do
      stub_request(:get, /api\.calendly\.com\/scheduled_events\?/)
        .to_return(status: 200, body: calendly_events_response.to_json, headers: { "Content-Type" => "application/json" })

      stub_request(:get, /api\.calendly\.com\/scheduled_events\/EVT001\/invitees/)
        .to_return(status: 200, body: invitee_response.to_json, headers: { "Content-Type" => "application/json" })
    end

    it "returns AppointmentDTOs" do
      dtos = adapter.fetch_appointments(date_range: Date.current..Date.current)
      expect(dtos).to be_an(Array)
      expect(dtos.length).to eq(1)
    end

    it "maps Calendly fields to DTO" do
      dto = adapter.fetch_appointments(date_range: Date.current..Date.current).first

      expect(dto.external_id).to eq("EVT001")
      expect(dto.external_source).to eq("calendly")
      expect(dto.patient_first_name).to eq("Alex")
      expect(dto.patient_last_name).to eq("Rivera")
      expect(dto.patient_phone).to eq("5551234567")
      expect(dto.provider_last_name).to eq("Lee")
    end
  end

  describe "#parse_webhook" do
    let(:webhook_payload) do
      {
        event: "invitee.created",
        payload: {
          uri: "https://api.calendly.com/scheduled_events/EVT002/invitees/INV002",
          name: "Jordan Kim",
          email: "jordan@example.com",
          text_reminder_number: "+15559876543",
          status: "active",
          scheduled_event: {
            uri: "https://api.calendly.com/scheduled_events/EVT002",
            name: "Initial Consultation",
            start_time: "2025-05-18T10:00:00.000000Z",
            end_time: "2025-05-18T10:30:00.000000Z",
            event_memberships: [
              { user_name: "NP Priya Patel" }
            ]
          }
        }
      }.to_json
    end

    it "parses invitee.created into AppointmentDTO" do
      dto = adapter.parse_webhook(webhook_payload)

      expect(dto.external_id).to eq("EVT002")
      expect(dto.external_source).to eq("calendly")
      expect(dto.patient_first_name).to eq("Jordan")
      expect(dto.patient_last_name).to eq("Kim")
      expect(dto.patient_phone).to eq("5559876543")
    end

    let(:cancel_payload) do
      {
        event: "invitee.canceled",
        payload: {
          uri: "https://api.calendly.com/scheduled_events/EVT003/invitees/INV003",
          name: "Sam Okafor",
          text_reminder_number: "+15551111111",
          status: "canceled",
          scheduled_event: {
            uri: "https://api.calendly.com/scheduled_events/EVT003",
            start_time: "2025-05-18T11:00:00.000000Z",
            end_time: "2025-05-18T11:30:00.000000Z",
            event_memberships: [{ user_name: "Dr. Michael Chen" }]
          }
        }
      }.to_json
    end

    it "parses invitee.canceled with canceled status" do
      dto = adapter.parse_webhook(cancel_payload)

      expect(dto.external_id).to eq("EVT003")
      expect(dto.status).to eq("canceled")
    end
  end

  describe "#verify_webhook" do
    it "returns true for valid signature" do
      body = '{"event":"invitee.created"}'
      signature = OpenSSL::HMAC.hexdigest("SHA256", "whsec_test_signing_key", body)
      request = double("request", headers: { "Calendly-Webhook-Signature" => "v1=#{signature}" }, raw_post: body)

      expect(adapter.verify_webhook(request)).to eq(true)
    end

    it "returns false for invalid signature" do
      request = double("request", headers: { "Calendly-Webhook-Signature" => "v1=invalid" }, raw_post: '{"event":"test"}')

      expect(adapter.verify_webhook(request)).to eq(false)
    end
  end
end
