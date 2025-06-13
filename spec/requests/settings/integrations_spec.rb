require "rails_helper"

RSpec.describe "Settings::Integrations", type: :request do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant, role: :manager) }

  before { sign_in user }

  describe "GET /settings/integrations" do
    it "returns success" do
      get settings_integrations_path
      expect(response).to have_http_status(:ok)
    end

    it "lists connected integrations" do
      create(:integration, tenant: tenant, adapter_type: "fhir", status: "active")
      get settings_integrations_path
      expect(response.body).to include("Connected")
      expect(response.body).to include("FHIR")
    end

    it "shows available integrations to connect" do
      get settings_integrations_path
      expect(response.body).to include("Available")
      expect(response.body).to include("Connect")
    end
  end

  describe "GET /settings/integrations/new" do
    it "shows the connect form for a type" do
      get new_settings_integration_path(type: "calendly")
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Calendly")
    end
  end

  describe "POST /settings/integrations" do
    it "creates a new integration" do
      expect {
        post settings_integrations_path, params: {
          adapter_type: "calendly",
          credentials: { api_key: "test_key", webhook_signing_key: "test_secret", organization_uri: "https://api.calendly.com/organizations/ORG1" }
        }
      }.to change(Integration, :count).by(1)

      expect(response).to redirect_to(settings_integrations_path)
    end
  end

  describe "DELETE /settings/integrations/:id" do
    it "disconnects the integration" do
      integration = create(:integration, tenant: tenant, adapter_type: "fhir")
      expect {
        delete settings_integration_path(integration)
      }.to change(Integration, :count).by(-1)

      expect(response).to redirect_to(settings_integrations_path)
    end
  end
end
