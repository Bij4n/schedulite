require "rails_helper"

RSpec.describe "Settings::Integrations", type: :request do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant, role: :admin) }

  before { sign_in user }

  describe "GET /settings/integrations" do
    it "returns success" do
      get settings_integrations_path
      expect(response).to have_http_status(:ok)
    end

    it "lists connected integrations" do
      create(:integration, tenant: tenant, adapter_type: "fhir", status: "active")
      get settings_integrations_path
      expect(response.body).to include("fhir")
    end

    it "shows empty state when no integrations" do
      get settings_integrations_path
      expect(response.body).to include("No integrations")
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
