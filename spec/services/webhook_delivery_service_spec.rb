require "rails_helper"

RSpec.describe WebhookDeliveryService do
  let(:tenant) { create(:tenant) }
  let(:provider) { create(:provider, tenant: tenant) }
  let(:patient) { create(:patient, tenant: tenant, first_name: "Alex") }
  let(:appointment) { create(:appointment, tenant: tenant, provider: provider, patient: patient) }

  let!(:subscription) do
    WebhookSubscription.create!(
      tenant: tenant,
      url: "https://partner.example.com/webhooks",
      secret: "webhook_secret_123",
      events: "appointment.status_changed"
    )
  end

  before do
    stub_request(:post, "https://partner.example.com/webhooks")
      .to_return(status: 200)
  end

  describe ".call" do
    it "sends POST to subscriber URL" do
      described_class.call(
        tenant: tenant,
        event: "appointment.status_changed",
        payload: { appointment_id: appointment.id, status: "checked_in" }
      )

      expect(a_request(:post, "https://partner.example.com/webhooks")).to have_been_made
    end

    it "signs the payload with subscriber's secret" do
      described_class.call(
        tenant: tenant,
        event: "appointment.status_changed",
        payload: { appointment_id: appointment.id, status: "checked_in" }
      )

      expect(a_request(:post, "https://partner.example.com/webhooks")
        .with { |req| req.headers["X-Webhook-Signature"].present? })
        .to have_been_made
    end

    it "includes event type in payload" do
      described_class.call(
        tenant: tenant,
        event: "appointment.status_changed",
        payload: { appointment_id: appointment.id, status: "checked_in" }
      )

      expect(a_request(:post, "https://partner.example.com/webhooks")
        .with { |req| JSON.parse(req.body)["event"] == "appointment.status_changed" })
        .to have_been_made
    end

    it "skips subscriptions that don't match the event" do
      subscription.update!(events: "appointment.created")

      described_class.call(
        tenant: tenant,
        event: "appointment.status_changed",
        payload: { appointment_id: appointment.id }
      )

      expect(a_request(:post, "https://partner.example.com/webhooks")).not_to have_been_made
    end
  end
end
