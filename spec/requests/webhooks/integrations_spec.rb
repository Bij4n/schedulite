require "rails_helper"

RSpec.describe "Webhooks::Integrations", type: :request do
  let(:tenant) { create(:tenant) }
  let(:integration) { create(:integration, tenant: tenant, adapter_type: "calendly") }

  let(:adapter) { instance_double(Integrations::Adapter) }
  let(:dto) do
    Integrations::AppointmentDTO.new(
      external_id: "cal_789",
      external_source: "calendly",
      patient_first_name: "Jordan",
      patient_last_name: "Kim",
      patient_phone: "5559876543",
      provider_first_name: "Sarah",
      provider_last_name: "Lee",
      starts_at: Time.current.change(hour: 10, min: 0)
    )
  end

  before do
    allow(Integrations::AdapterFactory).to receive(:build).and_return(adapter)
    allow(adapter).to receive(:supports_webhooks?).and_return(true)
    allow(adapter).to receive(:verify_webhook).and_return(true)
    allow(adapter).to receive(:parse_webhook).and_return(dto)
  end

  describe "POST /webhooks/integrations/:integration_id" do
    it "creates an appointment from the webhook payload" do
      expect {
        post webhooks_integration_path(integration), params: { event: "invitee.created" }, as: :json
      }.to change(Appointment, :count).by(1)

      expect(response).to have_http_status(:ok)
    end

    it "returns 404 for unknown integration" do
      post webhooks_integration_path(integration_id: 999999), params: {}, as: :json
      expect(response).to have_http_status(:not_found)
    end

    it "returns 403 if webhook verification fails" do
      allow(adapter).to receive(:verify_webhook).and_return(false)
      post webhooks_integration_path(integration), params: {}, as: :json
      expect(response).to have_http_status(:forbidden)
    end
  end
end
